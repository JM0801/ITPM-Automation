

import requests
from bs4 import BeautifulSoup
import json
import re
from datetime import datetime
from datetime import timedelta
import sys
import getopt
import pandas as pd

headers = {
    'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:128.0) Gecko/20100101 Firefox/128.0',
    'Accept': '*/*',
    'Accept-Language': 'en-US,en;q=0.5',
    # 'Accept-Encoding': 'gzip, deflate, br, zstd',
    'Content-Type': 'application/x-www-form-urlencoded',
    'X-Requested-With': 'XMLHttpRequest',
    'Origin': 'https://www.investing.com',
    'Connection': 'keep-alive',
    'Referer': 'https://www.investing.com/earnings-calendar/',
    'Content-Length': '143',
}

data = {
    'country[]': '5',
#    'dateFrom': '2024-09-01',
#    'dateTo': '2024-12-31',
    'currentTab': 'custom',
    'limit_from': '16',
    'byHandler' : 'true',
    'submitFilters' : '0',
#    'last_time_scope' : '1732665600',
}

def validate_args(argv) -> (datetime,datetime,bool):
    try:
        opts, args = getopt.getopt(argv,"hs:e:",["help","startdate=","enddate="])
    except Exception as err:
        print(f" Error : ",err)
        print(f" Usage : {sys.argv[0]} -s <dd-mm-yy> -e <dd-mm-yy>")
        print(f"       or {sys.argv[0]} --startdate <dd-mm-yy> --enddate <dd-mm-yy>")
        sys.exit(2)
    else:
        ## Exception cann't handle if no opts are passed via argv. sys.argv[1] can handle it but can't read all params that are passed
        if not opts:
            print(f"  Printing help to run  {sys.argv[0]}... ")
            print(f"  Usage : {sys.argv[0]} -s <dd-mm-yy> -e <dd-mm-yy>")
            print(f"      or {sys.argv[0]} --startdate <dd-mm-yy> --enddate <dd-mm-yy>")
            sys.exit(2)

        for opt, arg in opts:
            if opt in ('-h','--help'):
                print(f"  Usage : {sys.argv[0]} -s <dd-mm-yy> -e <dd-mm-yy>")
                print(f"       or {sys.argv[0]} --startdate <dd-mm-yy> --enddate <dd-mm-yy>")
                sys.exit(2)
            elif opt in ('-s', '--startdate'):
                startdate = datetime.strptime(arg,"%d-%m-%Y")
                #print ('start date :', startdate)
            elif opt in ('-e', '--enddate'):
                enddate = datetime.strptime(arg,"%d-%m-%Y")
                #print ('end date :', enddate)
    return(startdate,enddate,True)

def reformat_response_df(response_next):
    lines = response_next.splitlines()
    rows = []
    current_date = ""

    for line in lines:
        if line.strip():  # Skip empty lines
            line = line.replace('--/','')
            
            if '2024' in line:
                # It's a date line
                current_date = line.strip()
            else:
                # It's a company data line
                parts = line.split()
                company = ' '.join(parts[:-3])
                eps_estimate = parts[-3]
                revenue_estimate = parts[-2]
                market_cap = parts[-1]
                rows.append([current_date, company, eps_estimate, revenue_estimate, market_cap])
    df = pd.DataFrame(rows, columns=['Date', 'Company', 'EPS Estimate', 'Revenue Estimate', 'Market Cap'])
    return df            
    
if __name__ == "__main__":
    (startdate,enddate,isValid) = validate_args(sys.argv[1:])
    ## To hold all responses (every 15 days responses)
    fullresponse=''
    need_to_continue = False

    print(f"START OF PROCESSING INVESTING DATA FROM {startdate} to {enddate}")
    if (isValid):
        data['dateFrom']=startdate
        enddate_temp = startdate + timedelta(days=15) 
        if (enddate_temp < enddate) :
            data['dateTo']=enddate_temp
            need_to_continue = True
        else:
            data['dateTo']=enddate
            need_to_continue = False

        
        if (need_to_continue == False):
            print(f" Downloading data from { data['dateFrom'] } to { data['dateTo'] }")
            response = requests.post('https://www.investing.com/earnings-calendar/Service/getCalendarFilteredData',headers=headers,data=data)
            soup = BeautifulSoup(response.content, "lxml").text
            jsondata = json.loads(soup)
            fullresponse =  jsondata['data']
            
        enddate_temp = startdate
        while(need_to_continue):
            #print(type(response))
            startdate_temp = enddate_temp + timedelta(days=1) 
            enddate_temp = startdate_temp + timedelta(days=15) 
            if (enddate_temp < enddate) :
                data['dateFrom']=startdate_temp
                data['dateTo']=enddate_temp
                need_to_continue = True
            else:
                data['dateFrom']=startdate_temp
                data['dateTo']=enddate
                need_to_continue = False
            
            print(f" Downloading data from { data['dateFrom'] } to { data['dateTo'] }")
            response = requests.post('https://www.investing.com/earnings-calendar/Service/getCalendarFilteredData',headers=headers,data=data)

            #print(response.__dict__)
            #print(response.content)

            ## Converts to str by default
            soup = BeautifulSoup(response.content, "lxml").text
            #soup = BeautifulSoup(response.content, features="html.parser").text
            jsondata = json.loads(soup)
            fullresponse = fullresponse + jsondata['data']
        
        ## Removing extra spaces in between text
        ## Note: Not possible to remove \n\t in soup
        fullresponse=re.sub(' ','',fullresponse)
        
        ## Replacing tr with special charcter for future replacement
        fullresponse=re.sub('<[^<tr]+?>',';;',fullresponse)
        
        ## Removing tags
        fullresponse=re.sub('<[^<]+?>','',fullresponse)
        #print(fullresponse)

        ## Removing empty lines
        fullresponse = re.sub(r'\n\s*\n', '\n', fullresponse)

        ## Below are to format the fullresponse to display
        fullresponse = re.sub(r'\n', ',,', fullresponse)
        fullresponse = re.sub(r'\t', '', fullresponse)
        fullresponse = re.sub(r',,/', '/', fullresponse)
        fullresponse = re.sub(r'\/s+', '/', fullresponse)
        fullresponse = re.sub(r',,;;,,', '\n', fullresponse)
        fullresponse = re.sub(r'^,,|;;,,|;;', '', fullresponse)
        fullresponse = re.sub(r'\n\s*\n', '\n', fullresponse)
        fullresponse = re.sub(r',,', '\t', fullresponse)
        #fullresponse = re.sub(r';; ;; ;;|;; ;;| ;; ', '\n', fullresponse)
        #fullresponse = re.sub(r';;', '', fullresponse)
        #fullresponse = re.sub(r'\n\s*\n', '\n', fullresponse)
        
           
## Writing to Excel file
filename = 'earning_calender'+ ".xlsx"
df = reformat_response_df(fullresponse)
with pd.ExcelWriter(filename, engine='xlsxwriter') as writer:
    # Write the DataFrame to the specified Excel sheet
    df.to_excel(writer, sheet_name='Earning Calender', index=False)

    workbook = writer.book
    worksheet = writer.sheets['Earning Calender']

    # Auto-adjust the column widths
    for i, col in enumerate(df.columns):
        # Find the maximum length of the column name and the data
        max_length = max(df[col].astype(str).map(len).max(), len(col))
        # Set the column width
        worksheet.set_column(i, i, max_length + 2)  # Adding a little extra space

print(f"Successfully written the contents to file: {filename}")



