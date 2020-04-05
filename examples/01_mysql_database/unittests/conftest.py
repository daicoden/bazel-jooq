from pytest import fixture
import mysql.connector

@fixture
mydb = mysql.connector.connect(
        host="$(DB_HOST)",
        port="$(DB_PORT)",
        user="$(DB_USER)",
        passwd="$(DB_PASSWORD)",
)
