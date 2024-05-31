import pandas as pd
from selenium import webdriver
from selenium.webdriver.common.by import By
import calendar

class BillboardCrawler:
    def __init__(self, webdriver: webdriver.Chrome):
        self.driver = webdriver
        self.data = None
    
    '''Takes info outputted from scrapeInfo(). Place the scraped info into a data frame.'''

    def buildBillboard(self, data: list) -> pd.DataFrame:
        cols=["song","rank", "artist","last_week","peak_position","weeks_on_chart","saturday"]
        billboard = pd.DataFrame(data, columns=cols)
        self.data = billboard
    
    '''Takes a date url string.
    Returns a list of records for one week.
    '''

    def scrapeInfo(self, dateStr: str) -> list[list]:
        url = "http://www.billboard.com/charts/hot-100/" + dateStr +"/"
        self.driver.get(url)
        
        # Scrape rank information, also artist name
        rankElements = self.driver.find_elements(By.CLASS_NAME, "c-label")
        exclude = {'NEW','RE- ENTRY', ''}
        rankInfo = [a.text for a in rankElements if a.text not in exclude][3:]     # First 3 elements are not needed, cut them off
        
        # Scrape song titles
        y = self.driver.find_elements(By.ID, "title-of-a-story")
        songTitles = [[a.text] for a in y if a.text!=''][:100]
        
        # Combine --> Ex: ['Blank Space] + ['Taylor Swift', 1, 1, 2] -> ['Blank Space', 'Taylor Swift', 1, 1, 2]
        res = []
        i,j = 0,0
        while j < len(songTitles):
            res.append(songTitles[j] + rankInfo[i:i+5] + [dateStr])
            j+=1
            i+=5
            
        return res
    
    '''
    Returns a string list of Saturday dates in the format 'Year-month-day', ex: '2024-04-20', given a list of tuples in the format (Year, month)
    https://www.billboard.com/charts/hot-100/2024-04-20/

    Re: invalid saturdays. The first Saturday in the month below is in the second week, and there is no Saturday in the last week.
    The 0 indicates that the date is not part of the month, so skip it.

    [[0, 0, 0, 0, 0, 0, 1],
    [2, 3, 4, 5, 6, 7, 8],
    [9, 10, 11, 12, 13, 14, 15],
    [16, 17, 18, 19, 20, 21, 22],
    [23, 24, 25, 26, 27, 28, 29],
    [30, 31, 0, 0, 0, 0, 0]]
    
    '''
    def getSaturdays(self, months: list[tuple[int, int]]) -> list[str]:
        res = []
        obj = calendar.Calendar()
        for m in months:   # ex: m = (2023, 8)
            cal = obj.monthdayscalendar(m[0],m[1])
            for week in cal:
                saturday = week[5]
                if saturday == 0: continue   # No Saturday in this week, skip to the next
                dateStr = str(m[0]) + "-" + '{:02d}'.format(m[1]) + "-" + '{:02d}'.format(saturday)  # ex: 2024-05-26
                res.append(dateStr)
        return res

    '''
    date1: '2023-08'
    date2: '2024-05'

    Returns: List of tuples of (year, month) within the date range.
    '''

    def returnDates(self, date1, date2) -> list[str]:
        lst = pd.date_range(date1, date2, freq='MS').strftime("%Y-%m").tolist()
        res = [(int(x[:4]), int(x[-2:])) for x in lst]
        return res

