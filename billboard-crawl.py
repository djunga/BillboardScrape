from selenium import webdriver
from BillboardCrawler import BillboardCrawler

# Initiate Chrome Web Driver

options = webdriver.ChromeOptions()
options.add_argument('--headless=new')
driver = webdriver.Chrome(options=options)

crawler = BillboardCrawler(driver)

# Take input args for date
date1 = "2024-05" #input('Enter First Date in the format YYYY-MM: ')
date2 = "2024-05" #input('Enter Second Date in the format YYYY-MM: ')
output_filename = "billboard_" + date1 + "_" + date2 + ".csv"    # input('Enter the name of the output CSV file in the format <name>.csv, or write None
# to skip output)

print("Selected Timeframe:", date1, "->", date2)
print("Output filename:")

# TODO tqdm

saturdays = crawler.getSaturdays(crawler.returnDates(date1, date2))

# rawInfo = [crawler.scrapeInfo(saturday) for saturday in saturdays]

rawInfo = []

for saturday in saturdays:
    rawInfo.extend(crawler.scrapeInfo(saturday))

crawler.buildBillboard(rawInfo)

# Output to .csv
crawler.data.to_csv(output_filename)