import json


def test_database_config(database_config):
    assert database_config == json.loads("""
        {
            "host": "localhost", 
            "port": 3306, 
            "username": "root", 
            "password": "", 
            "jdbc_connection_string": "jdbc:mysql://localhost:3306?serverTimezone=UTC"
        }
        """)
