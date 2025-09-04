import requests
from bs4 import BeautifulSoup
import json
from datetime import datetime

def scrape_example():
    """간단한 크롤링 테스트"""
    try:
        url = "https://httpbin.org/json" 
        response = requests.get(url)
        
        if response.status_code == 200:
            data = response.json()
            print("✅ 크롤링 성공!")
            print(f"시간: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
            print("테스트 완료!")
            return data
        else:
            print(f"❌ 요청 실패: {response.status_code}")
            return None
            
    except Exception as e:
        print(f"❌ 에러 발생: {e}")
        return None

if __name__ == "__main__":
    scrape_example()
