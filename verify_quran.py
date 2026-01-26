import json
import os

def verify_quran_data():
    file_path = r'd:\xampp\htdocs\guran\assets\data\quran.json'
    if not os.path.exists(file_path):
        print(f"Error: {file_path} not found")
        return

    with open(file_path, 'r', encoding='utf-8') as f:
        try:
            data = json.load(f)
            print(f"Total Surahs: {len(data)}")
            
            # Check a few surahs for content
            missing_content = []
            for surah in data:
                surah_name = surah.get('name_arabic', 'Unknown')
                content = surah.get('text_uthmani') or surah.get('content')
                if not content:
                    missing_content.append(surah_name)
            
            if missing_content:
                print(f"Warning: {len(missing_content)} surahs are missing text content.")
                print(f"Sample missing: {missing_content[:5]}")
            else:
                print("Success: All surahs have text content.")
                
            # Check total Juz
            juz_set = set()
            for surah in data:
                juz_set.add(surah.get('juz_number') or surah.get('juz'))
            print(f"Juz present: {sorted(list(juz_set))}")

        except Exception as e:
            print(f"Error parsing JSON: {e}")

if __name__ == "__main__":
    verify_quran_data()
