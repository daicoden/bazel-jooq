import mysql.connector


def test_database_can_be_created():


def test_database_can_be_deleted():

mydb = mysql.connector.connect(
        host="$(DB_HOST)",
        port="$(DB_PORT)",
        user="$(DB_USER)",
        passwd="$(DB_PASSWORD)",
)

cursor = mydb.cursor()

if "01_mysql_flyway_migration" in cursor.execute("SHOW DATABSES"):


