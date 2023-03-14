from bs4 import BeautifulSoup
import json
import os
import requests


# creating a file with html files of top 50 pages site
headers = {
        'accept': '*/*',
        "user-agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36"
    }
for i in range(1,51):
    url = 'https://somon.tj/transport/legkovyie-avtomobili/' + '?page='+str(i)
    req = requests.get(url,headers=headers)
    main  = req.text
    # creating a package
    path = "C:/Users/abuzu/OneDrive/Рабочий стол/web_scraping/somon_tj/pages/page"+str(i)
    os.mkdir(path)
    with open("somon_tj/pages/page"+str(i)+"/page"+str(i)+".html","w",encoding="utf-8") as main_file:
        # writing a page
        main_file.write(main)
print('main page files created successfully')
# creating json file with car links
main_link = "https://somon.tj"
for i in range(1,51):
    car_links = {}
    with open("somon_tj/pages/"+"page"+str(i)+"/"+"page"+str(i)+".html","r",encoding="utf-8") as main_file:
        page = main_file.read()
    soup = BeautifulSoup(page,"lxml")
    car_frame = soup.findAll("li",class_="card _verified") #list-simple__output js-list-simple__output
    for car in range(len(car_frame)):
        # adding car-name and link to hashmap
        car_links[car_frame[car].find("a",class_="card__title-link").get("content")] = main_link+car_frame[car].find("a",class_="card__title-link").get("href")
    with open("somon_tj/pages/"+"page"+str(i)+"/"+"car_page"+str(i)+".json","w",encoding='utf-8') as jsonfile:
        # creating a json file from hashmap
        json.dump(car_links,jsonfile,indent=4,ensure_ascii=False)
print('json files created ')

for i in range(1,51):
    with open("somon_tj/pages/page"+str(i)+"/car_page"+str(i)+".json","r",encoding='UTF-8') as jsonfile:
        cars = json.load(jsonfile)
    print(cars)
    path = "C:/Users/abuzu/OneDrive/Рабочий стол/web_scraping/somon_tj/pages/page"+str(i)+"/car_page"+str(i)
    # creating a package to each page package
    os.mkdir(path)
    for car,link in cars.items():
        url = link
        req = requests.get(url, headers=headers)
        main = req.text
        with open("somon_tj/pages/page" + str(i) + "/car_page" + str(i)+"/"+car+".html", "w", encoding="utf-8") as car_file:
            #writing a file from a car-page
            car_file.write(main)
print('html car data uploaded successfully')