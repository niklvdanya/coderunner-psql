# Moodle CodeRunner with PostgreSQL Support

This project consists of two main components:
1. **JobeInABox**: A Dockerized version of the Jobe server, which is used for running student code in a sandboxed environment.
2. **Modified CodeRunner**: A customized version of the CodeRunner question type for Moodle, where the SQL question type uses **PostgreSQL** instead of the default SQLite.

## Prerequisites

Before you begin, ensure you have the following:
- **Docker**: Installed and running on your system.
- **Moodle**: Installed and configured on your server.
- **PostgreSQL**: Installed and running, as the modified CodeRunner uses PostgreSQL for SQL questions.

---

## Installation

### JobeInABox

1. Pull this repository from GitHub:
   ```bash
   git clone https://github.com/niklvdanya/coderunner-psql.git
   cd coderunner-psql/jobeinabox

2. Build the Docker image:
    ```bash
    sudo docker build . -t my/jobeinabox --build-arg TZ="Europe/Amsterdam"

3. Run the Docker container:

    ```bash
    sudo docker run -d -p 4000:80 --name jobe my/jobeinabox
    ```

    This will start the Jobe server on port 4000.

### Modified CodeRunner

1. Move the coderunner folder to your Moodle's question type directory:

    ```bash
    cp -r coderunner /path/to/moodle/question/type
    ```

    Typically, the path is:

    ```bash
    /var/www/html/moodle/question/type

2. Set the correct permissions:

    ```bash
    sudo chown -R www-data:www-data /path/to/moodle/question/type/coderunner
    sudo chmod -R 755 /path/to/moodle/question/type/coderunner

3. Install the plugin:

    Log in to your Moodle server as an administrator.

    Go to Site Administration → Notifications.

    Moodle will detect the new plugin and prompt you to install it. Click Upgrade.

4. Configure CodeRunner:

    Go to Site Administration → Plugins → Question Types → CodeRunner.

    Set the Jobe server URL to http://localhost:4000 (or the appropriate address if Jobe is running elsewhere).

### Database Initialization
The jobeinabox directory contains an init.sql file, which is used to initialize the PostgreSQL database for the Jobe server. This file creates tables and grants necessary privileges to the jobe_user