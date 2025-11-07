import unittest
import json
from main import generate_prayer, summarize_text, create_prayer, load_database, save_database

class TestPrayerGenerator(unittest.TestCase):
    def setUp(self):
        self.db_file = "/workspace/prayai/database.json"
        with open(self.db_file, "w") as f:
            json.dump([], f)

    def test_generate_prayer(self):
        """
        Tests that the generate_prayer function returns a non-empty string and saves the prayer to the database.
        """
        user_input = "I want to pray for my cat."
        prayer = generate_prayer(user_input)
        self.assertIsInstance(prayer, str)
        self.assertNotEqual(prayer, "")

        database = load_database()
        self.assertEqual(len(database), 1)
        self.assertEqual(database[0]["prayer"], prayer)

    def test_summarize_text(self):
        """
        Tests that the summarize_text function returns a non-empty string.
        """
        text = "I want to pray for my family's health and for my upcoming exam."
        summary = summarize_text(text)
        self.assertIsInstance(summary, str)
        self.assertNotEqual(summary, "")

    def test_create_prayer(self):
        """
        Tests that the create_prayer function returns a non-empty string.
        """
        keywords = "family, health, exam"
        prayer = create_prayer(keywords)
        self.assertIsInstance(prayer, str)
        self.assertNotEqual(prayer, "")

    def test_database(self):
        """
        Tests that the load_database and save_database functions work correctly.
        """
        database = load_database()
        self.assertEqual(len(database), 0)

        new_prayer = {"keywords": "test", "prayer": "This is a test prayer."}
        database.append(new_prayer)
        save_database(database)

        new_database = load_database()
        self.assertEqual(len(new_database), 1)
        self.assertEqual(new_database[0], new_prayer)

if __name__ == "__main__":
    unittest.main()