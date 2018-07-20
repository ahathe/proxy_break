#!/usr/bin/env python3

from requests_html import HTMLSession
import re
from purl import URL
import aiohttp
import asyncio
import html5lib
from bs4 import BeautifulSoup
from flashtext import KeywordProcessor

keyword = KeywordProcessor()
session = HTMLSession()
headers = ("Name","Domain","URL","ICP","Location")


dict1 = ['11467.com','baidu.com','ygbid.com','sdsgwy.com','tianyancha.com','sogou.com','weather.com.cn','yaofangwang.com','99.com.cn','sina.com.cn','mapbar.com','iqilu.com' \
        ,'qianlima.com','guanfang123.com','zhaopin.com','wed114.cn','cnkang.com','haodf.com','sohu.com','qq.com','8684.cn','39.net' \
        ,'1688.com','so.com','999120.net','taobao.com','wikipedia.org','kanzhun.com','qichacha.com','51sxue.com','familydoctor.com.cn' \
        ,'qixin.com','lawxp.com','tgnet.com','sph.com.cn','haoqiu365.com','mingyihui.net','ifeng.com','ccoo.cn','xywy.com','liepin.com' \
        ,'honpu.com','quyiyuan.com','guahao.com','htbill.com','anxin.com','163.com']


jinan = ['商河县','济阳县','平阴县']
heze = ['定陶县','单县','成武县','东明县','曹县','郓城县','鄄城县','巨野县']
fubo = ['桓台','高青','沂源']
dying = ['利津县','垦利县','广饶县','东营县']
yantai = ['长岛县']
weifang = ['青州县','诸城县','寿光县','安丘县','高密县','昌邑县']
jinin = ['微山县','鱼台县','金乡县','嘉祥县','汶上县','泗水县','梁山县']
taian = ['东平县','宁阳县']
rizhao = ['五连县','莒县']
binzhou = ['邹平县','博兴县','惠民县','沾化县','无棣县','阳信县']
dezhou = ['齐河县','平原县','夏津县','武城县','陵县','临邑县','宁津县','庆云县']
liaocheng = ['茌平县','高唐县','阳谷县','东阿县','莘县','冠县']
lingxi = ['沂水县','沂南县','平邑县','蒙阴县','费县','郯城县','苍山县','莒南县','临沭县']

for each2 in dict1:
    keyword.add_keyword(each2)

   
def Get_html(Name):
    async def fetch(session,url):
        async with session.get(url) as response:
            return await response.text()

    async def look():
        async with aiohttp.ClientSession() as session:
            html = await fetch(session,'https://www.bing.com/search?q=intitle:%s' % Name)
            Get_N_url(Name,html)

    if __name__ == '__main__':
        loop = asyncio.get_event_loop()
        loop.run_until_complete(look())

def Get_N_url(Name,html):
    soup = BeautifulSoup(html,'lxml').find_all(target='_blank')
    length = len(soup) - 8
    for each in range(length):
        if soup[each].strong is None:
            pass
        else:
            Just(Name,soup[each].strong.string,soup[each].attrs['href'])

def Just(name,search_text,url):
    keyword.add_keyword(name)
    find = keyword.extract_keywords(search_text)
    if find == []:
        pass
    else:
        Urls = keyword.extract_keywords(url)
        if Urls == []:
            u = URL(url)
            Get_icp(name,u)
        
    keyword.remove_keyword(name)

def Get_icp(name,U):
    if len(U.subdomains()) == 3:
            num1 = U.subdomains()[-3]
            num2 = U.subdomains()[-2]
            num3 = U.subdomains()[-1]
    else:
        num1 = ''
        num2 = U.subdomains()[-2]
        num3 = U.subdomains()[-1]

    domain = num1+"."+num2+"."+num3
    r = session.get("http://www.beianbeian.com/search/%s" % domain)
    A1 = re.search("\/beianxinxi\/.*\<\/a\>",r.text)
    if A1 is None:
        pass
    else:
        ICP = re.search("\>.*\<",A1.group()).group().strip("<>")
        print(name,domain,U.as_string(),ICP,Get_loca(name))
        save(name,domain,U.as_string(),ICP,Get_loca(name))


def Get_loca(local):
    shi = re.search(".*市",local)
    if shi is not None:
        return shi.group()
    else:
        xian = re.search(".*县",local)
        if xian is not None:
            xians = xian.group()
            if xians in jinan:
                return "济南市"
            elif xians in heze:
                return "菏泽市"
            elif xians in fubo:
                return "淄博市"
            elif xians in dying:
                return "东营市"
            elif xians in yantai:
                return "烟台市"
            elif xians in weifang:
                return "潍坊市"
            elif xians in jinin:
                return "济宁市"
            elif xians in taian:
                return "泰安市"
            elif xians in rizhao:
                return "日照市"
            elif xians in binzhou:
                return "滨州市"
            elif xians in dezhou:
                return "德州市"
            elif xians in liaocheng:
                return "聊城市"
            elif xians in lingxi:
                return "临沂市"
        else:
            return local

def save(name='',domain='',url='',icp='',loca=''):
    saveing = name+"\t"+domain+"\t"+url+"\t"+icp+"\t"+loca
    with open("saveing_file.txt","a") as w:
        w.write(saveing+'\n')


def main():
    with open("Name.txt","r") as f:
        for each in f:
            each = each.strip()
            Get_html(each)
    w.close()
    f.close()
if __name__ == "__main__":
    main()
