# Employee Management System – AWS CI/CD Deployment Using Jenkins

## 1. Project Overview

This project demonstrates the deployment of a Java-based Employee Management System using AWS cloud infrastructure and a Jenkins Continuous Integration and Continuous Deployment (CI/CD) workflow.

The application is developed using Java, JSP, Jakarta Servlets, Maven, and MySQL. GitHub is used for source code management, Jenkins automates the build and deployment process, Apache Tomcat hosts the application, and Amazon RDS provides the relational database service.

The objective of this project is to automate application deployment and understand how different DevOps tools and AWS services work together in a real-world environment.

### Project Objectives

- Host a Java web application on AWS infrastructure.
- Use GitHub for source code management.
- Automate application builds using Maven.
- Configure Jenkins for CI/CD automation.
- Deploy WAR files to Apache Tomcat.
- Use Amazon RDS MySQL for database management.
- Configure AWS networking and security groups.
- Understand application deployment and troubleshooting.

---

## 2. Technologies and Tools Used

| Technology | Purpose |
|---|---|
| AWS EC2 | Hosts Jenkins and Tomcat servers |
| AWS VPC | Provides isolated cloud networking |
| Public Subnets | Hosts internet-facing resources such as an ALB, if configured |
| Private Subnets | Hosts application and database resources |
| Application Load Balancer | Distributes application traffic, if configured |
| Target Group | Registers application instances with the ALB, if configured |
| Amazon RDS MySQL | Managed relational database |
| Ubuntu 24.04 | Operating system for EC2 instances |
| Java 21 | Java runtime and development environment |
| Jenkins 2.580.2 | CI/CD automation server |
| Apache Maven | Builds and packages Java applications |
| Apache Tomcat 10 | Java web application server |
| Git | Version control |
| GitHub | Source code repository |
| SSH | Secure remote server administration |
| HTTP | Application and deployment communication |

---

## 3. Application Architecture

The intended application architecture is:

```text
                 Developer
                     |
                     |
                 GitHub
                     |
                     | Source Code
                     |
                  Jenkins
                EC2 Instance
                     |
                     | Maven Build
                     |
                 WAR File
                     |
                     | Deployment
                     |
               Tomcat Server
                EC2 Instance
                     |
                     | JDBC
                     |
              Amazon RDS MySQL
```

The application traffic architecture is:

```text
              Users / Browser
                     |
                     |
           Application Load Balancer
               Public Subnets
                     |
                     |
              Target Group
                     |
                     |
              Tomcat EC2
              Private Subnet
                     |
                     |
              Amazon RDS
              Private DB Subnets
```

Note: The ALB and target-group architecture should be documented as deployed only if those resources were actually created and verified. Otherwise, treat it as the intended architecture.

### CI/CD Workflow

```text
Developer writes code
          |
          v
Push code to GitHub
          |
          v
Jenkins detects code changes
          |
          v
Jenkins Freestyle Job
          |
          v
GitHub Source Checkout
          |
          v
Maven Build
          |
          v
Run Unit Tests
          |
          v
Generate WAR File
          |
          v
Deploy WAR to Tomcat
          |
          v
Application Verification
```

---

## 4. AWS Infrastructure

### AWS Region

```text
Europe (Stockholm)
Region: eu-north-1
```

### EC2 Instances

Two EC2 instances were used for the application deployment workflow.

| Instance | Purpose | Private IP |
|---|---|---|
| Jenkins EC2 | CI/CD automation server | 10.0.1.70 |
| Tomcat EC2 | Java application server | 10.0.11.44 |

Instance type, public IP, storage size, and availability-zone details should be added from the actual EC2 configuration.

### Network Architecture

The VPC provides network isolation for the application infrastructure.

The intended network structure is:

```text
VPC
 |
 +-- Public Subnets
 |      |
 |      +-- Application Load Balancer
 |
 +-- Private Application Subnets
 |      |
 |      +-- Tomcat EC2
 |
 +-- Private Database Subnets
        |
        +-- Amazon RDS MySQL
```

Add the actual VPC ID, CIDR range, subnet IDs, and availability zones from AWS.

### Security Group Configuration

The following table describes the intended network access policy.

| Security Group | Port | Allowed Source | Purpose |
|---|---:|---|---|
| Jenkins SG | 22 | Administrator IP | SSH administration |
| Jenkins SG | 8080 | Administrator IP | Jenkins dashboard |
| Tomcat SG | 22 | Jenkins/Admin access as required | Server administration |
| Tomcat SG | 8080 | Jenkins SG / ALB SG | Application and deployment traffic |
| RDS SG | 3306 | Tomcat SG | MySQL database connectivity |
| ALB SG | 80 | Internet, if public ALB is used | HTTP application traffic |

Security recommendations:

- Do not expose MySQL port 3306 publicly.
- Restrict Jenkins dashboard access to trusted administrator IP addresses.
- Allow Tomcat deployment access only from authorized sources.
- Use security-group references instead of broad IP ranges for internal communication where possible.
- Use HTTPS for production-facing application traffic.

---

## 5. Step 1 – Create and Configure Jenkins EC2

Create an Ubuntu EC2 instance in the selected AWS region.

Connect to the instance using EC2 Instance Connect or SSH.

Update Ubuntu packages:

```bash
sudo apt update
sudo apt upgrade -y
```

Check the operating system:

```bash
cat /etc/os-release
```

Check the private IP:

```bash
hostname -I
```

Install Java 21 if it is not already installed:

```bash
sudo apt install -y openjdk-21-jdk
```

Verify Java:

```bash
java -version
```

Expected Java version:

```text
openjdk version "21..."
```

### Install Jenkins

Create the keyring directory:

```bash
sudo mkdir -p /etc/apt/keyrings
```

Download the Jenkins repository key:

```bash
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key
```

Configure the Jenkins repository:

```bash
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] \
https://pkg.jenkins.io/debian-stable binary/" \
| sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
```

Update the package repository:

```bash
sudo apt update
```

Install Jenkins:

```bash
sudo apt install -y jenkins
```

Start Jenkins:

```bash
sudo systemctl start jenkins
```

Enable Jenkins at system startup:

```bash
sudo systemctl enable jenkins
```

Check Jenkins status:

```bash
sudo systemctl status jenkins
```

Verify the listening port:

```bash
sudo ss -lntp | grep 8080
```

### Access Jenkins Dashboard

Open the following address in your browser:

```text
http://JENKINS_PUBLIC_IP:8080
```

Retrieve the initial administrator password:

```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

Enter the password in the Jenkins setup page.

Complete the initial setup:

1. Install suggested plugins.
2. Create the first administrator account.
3. Configure the Jenkins URL.
4. Open the Jenkins dashboard.

### Jenkins Service Management Commands

Check Jenkins:

```bash
sudo systemctl status jenkins
```

Start Jenkins:

```bash
sudo systemctl start jenkins
```

Stop Jenkins:

```bash
sudo systemctl stop jenkins
```

Restart Jenkins:

```bash
sudo systemctl restart jenkins
```

View Jenkins logs:

```bash
sudo journalctl -u jenkins -f
```

Check Jenkins port:

```bash
sudo ss -lntp | grep 8080
```

Test Jenkins locally:

```bash
curl -I http://localhost:8080
```

---

## 6. Step 2 – Configure Git and Maven on Jenkins EC2

Install Git:

```bash
sudo apt install -y git
```

Verify Git:

```bash
git --version
```

Install Maven:

```bash
sudo apt install -y maven
```

Verify Maven:

```bash
mvn -version
```

### Configure Maven in Jenkins

1. Open Jenkins Dashboard.
2. Go to Manage Jenkins.
3. Open Tools.
4. Find Maven installations.
5. Add a Maven installation.
6. Set the name to:

```text
maven3
```

7. Enable automatic installation or configure the installed Maven path.
8. Save the configuration.

The Maven tool name must match the Maven installation selected in the Jenkins job.

---

## 7. Step 3 – Configure Tomcat EC2

Connect to the Tomcat EC2 instance.

Previously confirmed private IP:

```text
10.0.11.44
```

Update Ubuntu:

```bash
sudo apt update
```

Install Java:

```bash
sudo apt install -y openjdk-21-jdk
```

Verify Java:

```bash
java -version
```

Install Tomcat 10:

```bash
sudo apt install -y tomcat10
```

Start Tomcat:

```bash
sudo systemctl start tomcat10
```

Enable Tomcat at startup:

```bash
sudo systemctl enable tomcat10
```

Check Tomcat:

```bash
sudo systemctl status tomcat10
```

Check whether Tomcat is listening:

```bash
sudo ss -lntp | grep 8080
```

### Tomcat Configuration Files

Important configuration locations on Ubuntu:

```text
/etc/tomcat10/
/var/lib/tomcat10/
/var/log/tomcat10/
/var/lib/tomcat10/webapps/
```

Check Tomcat configuration:

```bash
sudo systemctl cat tomcat10
```

View Tomcat logs:

```bash
sudo journalctl -u tomcat10 -f
```

### Configure Tomcat Manager Access

Edit the Tomcat users configuration:

```bash
sudo nano /etc/tomcat10/tomcat-users.xml
```

Inside the appropriate configuration section, configure a dedicated deployment account:

```xml
<role rolename="manager-script"/>
<user username="jenkins-deploy"
      password="REPLACE_WITH_A_STRONG_PASSWORD"
      roles="manager-script"/>
```

Save the file.

Restart Tomcat:

```bash
sudo systemctl restart tomcat10
```

Check the service:

```bash
sudo systemctl status tomcat10
```

Important:

- Use a strong deployment password.
- Do not commit this password to GitHub.
- Restrict Tomcat Manager access through network security rules.
- Configure the Manager application to permit access from the authorized Jenkins server if its default access restriction blocks remote deployment.

---

## 8. Step 4 – Clone the GitHub Repository

GitHub repository:

```text
https://github.com/NujellaHitesh/employee-management-system.git
```

Default branch:

```text
main
```

Clone the repository on a machine with Git installed:

```bash
git clone https://github.com/NujellaHitesh/employee-management-system.git
```

Move into the project directory:

```bash
cd employee-management-system
```

Check the current branch:

```bash
git branch
```

Check repository files:

```bash
ls -la
```

The repository contains the Maven project structure:

```text
employee-management-system/
|
+-- src/
|   |
|   +-- main/
|       |
|       +-- java/
|       +-- resources/
|       +-- webapp/
|
+-- pom.xml
+-- README.md
+-- .gitignore
```

The exact source folders depend on the committed repository structure.

### Check Maven Configuration

Open the POM file:

```bash
cat pom.xml
```

The project uses Maven WAR packaging.

Previously configured dependencies included:

- Jakarta Servlet API 6.0
- Jakarta Server Pages API 3.1.1
- MySQL Connector/J 9.4.0

The build artifact name is:

```text
employee-management.war
```

Verify the actual Maven `finalName` and dependency declarations in `pom.xml`.

---

## 9. Step 5 – Build the Application Using Maven

Move into the application directory:

```bash
cd employee-management-system
```

Clean previous build output:

```bash
mvn clean
```

Compile and test the application:

```bash
mvn test
```

Build the application:

```bash
mvn clean package
```

The Maven build creates the WAR file under:

```text
target/
```

Expected artifact:

```text
target/employee-management.war
```

Verify the artifact:

```bash
ls -lh target/
```

Check WAR contents:

```bash
jar tf target/employee-management.war | head -30
```

The WAR file is the deployable Java web application package.

---

## 10. Step 6 – Configure Jenkins Freestyle Job

The project uses a Jenkins Freestyle job.

Previously configured job name:

```text
Employee-Management-CI-CD
```

### Create a Jenkins Job

1. Open Jenkins Dashboard.
2. Click New Item.
3. Enter:

```text
Employee-Management-CI-CD
```

4. Select Freestyle project.
5. Click OK.

### Configure Source Code Management

Under Source Code Management:

Select:

```text
Git
```

Repository URL:

```text
https://github.com/NujellaHitesh/employee-management-system.git
```

Branch Specifier:

```text
*/main
```

Save the configuration.

### Configure Build Triggers

A GitHub webhook can be used to trigger builds automatically after code pushes.

If configuring GitHub webhook:

1. Open the GitHub repository.
2. Go to Settings.
3. Open Webhooks.
4. Click Add webhook.
5. Configure the Jenkins webhook endpoint.
6. Select the appropriate push event.
7. Save the webhook.
8. Check webhook delivery status.

Jenkins must be reachable from GitHub for inbound webhook delivery. Do not expose the Jenkins dashboard broadly just to make webhooks work; use an appropriate secure ingress design.

### Configure Build Environment

Select the configured Maven installation:

```text
maven3
```

### Configure Build Steps

Choose:

```text
Invoke top-level Maven targets
```

Maven Version:

```text
maven3
```

Goals:

```text
clean test package
```

Save the job.

### Run the Jenkins Job

Click:

```text
Build Now
```

Open the build number and select:

```text
Console Output
```

Verify that:

- GitHub checkout succeeds.
- Maven dependencies resolve.
- Maven compilation succeeds.
- Tests execute.
- WAR packaging succeeds.

---

## 11. Step 7 – Deploy WAR to Tomcat

The WAR file generated by Maven must be deployed to the Tomcat application server.

The deployment endpoint is:

```text
http://TOMCAT_PRIVATE_IP:8080/manager/text
```

The application context path is:

```text
/employee-management
```

### Test Tomcat Manager Connectivity

From the Jenkins server, test connectivity:

```bash
nc -zv 10.0.11.44 8080
```

Check whether Tomcat responds:

```bash
curl -I http://10.0.11.44:8080
```

Test the Tomcat Manager API using authorized credentials:

```bash
curl -u jenkins-deploy \
"http://10.0.11.44:8080/manager/text/list"
```

Curl will request the password interactively.

### Deploy the WAR Manually

After the WAR file has been generated, run:

```bash
curl --fail --user jenkins-deploy \
--upload-file target/employee-management.war \
"http://10.0.11.44:8080/manager/text/deploy?path=/employee-management&update=true"
```

Enter the Tomcat deployment password when prompted.

Expected successful deployment response:

```text
OK - Deployed application at context path [/employee-management]
```

### Verify Deployment

Check the application endpoint:

```bash
curl -I http://10.0.11.44:8080/employee-management/
```

The exact response depends on application routing, authentication, and application health.

View Tomcat logs:

```bash
sudo journalctl -u tomcat10 -n 100 --no-pager
```

---

## 12. Step 8 – Automate WAR Deployment Through Jenkins

The deployment process can be added to the Jenkins Freestyle job after the Maven build.

### Configure Jenkins Credentials

In Jenkins:

1. Open Manage Jenkins.
2. Select Credentials.
3. Add a Username with password credential.
4. Username:

```text
jenkins-deploy
```

5. Password: use the Tomcat deployment password.
6. Assign a credential ID, for example:

```text
tomcat-deploy-credentials
```

Do not store deployment passwords directly in the Jenkins shell script.

### Configure Credentials Binding

Install or enable the Credentials Binding plugin if needed.

In the Freestyle job:

1. Open Configure.
2. Select Build Environment.
3. Enable secret text or username/password binding.
4. Bind the username/password credential.
5. Use the variables:

```text
TOMCAT_USER
TOMCAT_PASS
```

### Add Execute Shell Build Step

After the Maven build step, add an Execute Shell step:

```bash
#!/bin/bash

set -e

WAR_FILE="target/employee-management.war"

TOMCAT_HOST="10.0.11.44"

APP_PATH="/employee-management"

MANAGER_URL="http://${TOMCAT_HOST}:8080/manager/text"

echo "Checking WAR file..."

if [ ! -f "$WAR_FILE" ]; then
    echo "WAR file not found!"
    exit 1
fi

echo "WAR file found."

echo "Checking Tomcat connectivity..."

nc -zv "$TOMCAT_HOST" 8080

echo "Deploying application to Tomcat..."

curl --fail --silent --show-error \
    --user "$TOMCAT_USER:$TOMCAT_PASS" \
    --upload-file "$WAR_FILE" \
    "${MANAGER_URL}/deploy?path=${APP_PATH}&update=true"

echo "Deployment completed successfully."
```

Save the Jenkins job.

Run Build Now.

Verify the Console Output.

Important: This is a deployment build step, not a record of every setting already configured in the previous job. Ensure the credential binding is configured before running it. Also configure Tomcat Manager's remote access restriction securely.

---

## 13. Step 9 – Configure Amazon RDS MySQL

Amazon RDS provides the managed MySQL database service.

The application server connects to RDS using the MySQL protocol.

### Create an RDS MySQL Database

1. Open AWS Console.
2. Select RDS.
3. Click Create database.
4. Select Standard Create.
5. Choose MySQL.
6. Configure the database engine version.
7. Set the DB instance identifier.
8. Create a database administrator username and strong password.
9. Select the required instance class and storage.
10. Select the application VPC.
11. Configure a DB subnet group containing private subnets in multiple Availability Zones.
12. Disable public accessibility.
13. Attach the RDS security group.
14. Create the database.

Use your actual database instance identifier and settings in this documentation.

### RDS Network Configuration

The RDS security group should allow:

```text
Type: MySQL/Aurora
Protocol: TCP
Port: 3306
Source: Tomcat Security Group
```

Do not allow public access to the database.

### Find the RDS Endpoint

Open:

```text
AWS Console
  -> RDS
  -> Databases
  -> Select Database
  -> Connectivity & Security
```

Copy the endpoint.

Example placeholder:

```text
YOUR_RDS_ENDPOINT
```

Default MySQL port:

```text
3306
```

### Test Database Connectivity from Tomcat

Install MySQL client:

```bash
sudo apt update
sudo apt install -y mysql-client
```

Test the connection:

```bash
mysql -h YOUR_RDS_ENDPOINT \
-P 3306 \
-u YOUR_DB_USERNAME \
-p
```

Enter the database password when prompted.

Check database connectivity:

```bash
SHOW DATABASES;
```

Select the application database:

```sql
USE employee_management;
```

The database name and schema must match the actual application configuration.

### Application Database Configuration

The application must use the correct:

- JDBC driver
- RDS endpoint
- Database name
- Database username
- Database password
- MySQL port
- JDBC URL

Example JDBC URL:

```text
jdbc:mysql://YOUR_RDS_ENDPOINT:3306/employee_management
```

Example Java connection configuration:

```java
String url = "jdbc:mysql://YOUR_RDS_ENDPOINT:3306/employee_management";

String username = System.getenv("DB_USERNAME");

String password = System.getenv("DB_PASSWORD");

Connection connection =
    DriverManager.getConnection(url, username, password);
```

Use environment variables or a secure secrets manager for database credentials.

Do not commit real credentials or production endpoints containing sensitive information to GitHub.

### Verify MySQL JDBC Driver

The Maven project must include MySQL Connector/J.

Check the dependency:

```bash
grep -A8 -B2 "mysql-connector-j" pom.xml
```

Check whether the packaged WAR contains the driver:

```bash
jar tf target/employee-management.war | grep mysql-connector
```

If the driver is missing, review the Maven dependency scope and rebuild the WAR.

---

## 14. Step 10 – Application Access and Verification

### Direct Tomcat Application Access

```text
http://TOMCAT_PUBLIC_IP:8080/employee-management/
```

This direct URL is for testing only if Tomcat is intentionally reachable from the administrator's network.

### Application Load Balancer Access

If the ALB has been configured:

```text
http://YOUR_ALB_DNS_NAME/employee-management/
```

The ALB should have:

- An HTTP or HTTPS listener.
- A target group configured for the Tomcat application port.
- A suitable health check.
- Healthy registered targets.
- Network access to the Tomcat instances.

### Verify Application Components

| Component | Verification |
|---|---|
| Jenkins | Jenkins dashboard opens |
| GitHub | Repository checkout succeeds |
| Maven | Build succeeds |
| WAR | Artifact exists in target directory |
| Tomcat | Service is active |
| Deployment | Tomcat Manager confirms deployment |
| RDS | MySQL connection succeeds |
| Application | Employee application responds correctly |
| ALB | Target group shows healthy targets, if configured |

---

## 15. Troubleshooting

### Problem 1: Jenkins dashboard does not open

Check Jenkins:

```bash
sudo systemctl status jenkins
```

Check port 8080:

```bash
sudo ss -lntp | grep 8080
```

Test locally:

```bash
curl -I http://localhost:8080
```

Check the EC2 Security Group and public IP address.

### Problem 2: Jenkins build fails

Check:

```bash
java -version
mvn -version
git --version
```

Open Jenkins Console Output and inspect the first actual build error.

### Problem 3: Jenkins cannot connect to Tomcat

Check network connectivity:

```bash
nc -zv 10.0.11.44 8080
```

Check Tomcat:

```bash
sudo systemctl status tomcat10
```

Check security-group rules and Tomcat Manager access restrictions.

### Problem 4: Tomcat deployment fails with HTTP 401

Check:

- Tomcat username.
- Tomcat password.
- `manager-script` role.
- Jenkins credential binding.
- Correct Tomcat Manager URL.

### Problem 5: Tomcat deployment fails with HTTP 403

Check the Tomcat Manager application's remote-access restrictions and allow only the required trusted deployment source.

### Problem 6: Application returns HTTP 500

Inspect the Tomcat logs:

```bash
sudo journalctl -u tomcat10 -n 100 --no-pager
```

Check:

- JDBC driver availability.
- Database endpoint.
- Database credentials.
- Database name.
- SQL schema.
- Java application exceptions.
- Database network connectivity.

### Problem 7: MySQL connection fails

Test DNS:

```bash
getent hosts YOUR_RDS_ENDPOINT
```

Test port connectivity:

```bash
nc -zv YOUR_RDS_ENDPOINT 3306
```

Check the RDS security group, subnet routing, database status, and credentials.

### Problem 8: ALB target is unhealthy

If an ALB is configured:

- Check the target group's registered instances.
- Check target port 8080.
- Check health-check path.
- Check the application's HTTP response.
- Check the ALB and Tomcat security-group relationship.
- Review the target health reason in AWS.

---

## 16. Useful Linux Commands

### Jenkins Commands

```bash
sudo systemctl status jenkins
sudo systemctl start jenkins
sudo systemctl stop jenkins
sudo systemctl restart jenkins
sudo journalctl -u jenkins -f
sudo ss -lntp | grep 8080
```

### Tomcat Commands

```bash
sudo systemctl status tomcat10
sudo systemctl start tomcat10
sudo systemctl stop tomcat10
sudo systemctl restart tomcat10
sudo journalctl -u tomcat10 -f
```

### Networking Commands

```bash
hostname -I
ip addr
ip route
ping -c 4 8.8.8.8
curl -I http://localhost:8080
nc -zv 10.0.11.44 8080
```

### Git Commands

```bash
git status
git branch
git pull origin main
git add .
git commit -m "Update application"
git push origin main
```

### Maven Commands

```bash
mvn clean
mvn compile
mvn test
mvn package
mvn clean package
```

---

## 17. Screenshots and Documentation

Screenshots should be added to the repository so that readers can understand the complete deployment process.

Create this folder structure:

```text
employee-management-system/
|
+-- docs/
|   |
|   +-- images/
|       |
|       +-- 01-aws-vpc.png
|       +-- 02-aws-subnets.png
|       +-- 03-ec2-instances.png
|       +-- 04-security-groups.png
|       +-- 05-jenkins-dashboard.png
|       +-- 06-jenkins-job.png
|       +-- 07-github-repository.png
|       +-- 08-jenkins-console-output.png
|       +-- 09-maven-build-success.png
|       +-- 10-war-artifact.png
|       +-- 11-tomcat-manager.png
|       +-- 12-tomcat-deployment.png
|       +-- 13-rds-database.png
|       +-- 14-rds-connectivity.png
|       +-- 15-application-running.png
|       +-- 16-alb-target-health.png
|
+-- src/
+-- pom.xml
+-- README.md
+-- .gitignore
```

Only add screenshots for resources and steps that actually exist in your project.

### Display Screenshots in README

Use this Markdown syntax:

```markdown
## AWS Infrastructure

![AWS VPC](docs/images/01-aws-vpc.png)

## EC2 Instances

![EC2 Instances](docs/images/03-ec2-instances.png)

## Jenkins Dashboard

![Jenkins Dashboard](docs/images/05-jenkins-dashboard.png)

## Jenkins CI/CD Job

![Jenkins Job](docs/images/06-jenkins-job.png)

## Maven Build Success

![Maven Build](docs/images/09-maven-build-success.png)

## Tomcat Deployment

![Tomcat Deployment](docs/images/12-tomcat-deployment.png)

## RDS Database

![RDS Database](docs/images/13-rds-database.png)

## Application Running

![Employee Management Application](docs/images/15-application-running.png)
```

Screenshots should be clear and readable. Hide passwords, access keys, database credentials, session tokens, and other sensitive information before uploading.

---

## 18. Project Results

The project demonstrates the integration of cloud infrastructure and DevOps automation.

Key capabilities demonstrated:

- Created and configured AWS EC2-based Jenkins and Tomcat environments.
- Installed and configured Java and Jenkins.
- Integrated GitHub with Jenkins.
- Created a Jenkins Freestyle CI/CD job.
- Configured Maven to build and package a Java web application.
- Generated a WAR deployment artifact.
- Configured Tomcat 10 to host the Java web application.
- Deployed the application using Tomcat Manager.
- Prepared MySQL connectivity through Amazon RDS.
- Practiced application deployment and troubleshooting.

Final application availability and database operations should be verified before claiming a fully functional end-to-end deployment.

---

## 19. Learning Outcomes

Through this project, I gained practical experience in:

- AWS EC2 provisioning and Linux server administration.
- VPC networking and security-group configuration.
- Jenkins installation and CI/CD automation.
- GitHub source code integration.
- Maven build and dependency management.
- Java WAR packaging.
- Apache Tomcat application deployment.
- MySQL and Amazon RDS connectivity.
- SSH and network troubleshooting.
- CI/CD workflow automation.

---

## 20. Future Improvements

Possible improvements to this project include:

- Implement a Declarative Jenkins Pipeline using Jenkinsfile.
- Add automated webhook-triggered deployments.
- Configure HTTPS using an SSL certificate.
- Store application secrets in AWS Secrets Manager.
- Add application monitoring and CloudWatch alarms.
- Implement automated rollback.
- Add Docker containerization.
- Integrate static code analysis and security scanning.
- Implement deployment strategies for high availability.

---

## 21. Repository

GitHub:

https://github.com/NujellaHitesh/employee-management-system

Branch:

```text
main
```

Project:

```text
Employee Management System – AWS CI/CD Deployment Using Jenkins
```

**Author:** Nujella Hitesh Babu

**Domain:** Cloud Computing / DevOps / AWS

**Project Type:** Hands-on CI/CD and Cloud Deployment Project


## Project Screenshots

Click on any screenshot below to view the full image.

### GitHub Repository
[01 - GitHub Repository](docs/images/01-GitHub-Repository.png)

### Jenkins CI/CD
[02 - Jenkins Build Success](docs/images/02-Jenkins-Build-Success.png)

[03 - Jenkins Freestyle Configuration](docs/images/03-Jenkins-Freestyle-Configuration.png)

[04 - Jenkins Git Configuration](docs/images/04-Jenkins-Git-Configuration.png)

[16 - Jenkins Build History](docs/images/16-Jenkins-Build-History.png)

[17 - Jenkins Archived WAR](docs/images/17-Jenkins-Archived-WAR.png)

### AWS Infrastructure
[05 - AWS Target Group Healthy](docs/images/05-AWS-Target-Group-Healthy.png)

[06 - AWS Load Balancer](docs/images/06-AWS-Load-Balancer.png)

[07 - AWS ALB Listener](docs/images/07-AWS-ALB-Listener.png.png)

[08 - AWS EC2 Instances](docs/images/08-AWS-EC2-Instances.png.png)

[09 - AWS VPC and Subnets](docs/images/09-AWS-VPC-Subnets.png.png)

[10 - AWS Security Groups](docs/images/10-AWS-Security-Groups.png.png)

### Database Configuration
[11 - AWS RDS Database](docs/images/11-AWS-RDS-Database.png.png)

[12 - AWS RDS Connectivity](docs/images/12-AWS-RDS-Connectivity.png.png)

[15 - MySQL Employee Records](docs/images/15-MySQL-Employee-Records.png)

### Application Screenshots
[13 - Employee Application Home](docs/images/13-Employee-App-Home.png.png)

[14 - Employee Records](docs/images/14-Employee-Records.png.png)
