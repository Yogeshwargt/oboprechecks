# version 1.0 - Eryilmaz, Akif Muhammed
# >>>> Initial version
# version 1.1 - Magrassi, Leandro
# >>>> add additional fields in the csv file 
# version 1.2 - Eryilmaz, Akif Muhammed
# >>>> Adding replay tags to the product file
# version 1.3 - Magrassi, Leandro
# >>>> Split the script into Prod and SG

import csv
import lxml.etree as etree

with open('vtr_SGList.csv') as f:
    reader = csv.DictReader(f, delimiter=';')
    for row in reader:
        servicegroup = etree.fromstring("""<?xml version="1.0" encoding="utf-8" ?><TVAMain xml:lang="es" xmlns="urn:tva:metadata:2010" xmlns:mpeg7="urn:tva:mpeg7:2008" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="urn:tva:metadata:2010 http://www.broadcastingdata.com/dataimport/tva/tva1.6/tva_metadata_3-1_v161.xsd"><ProgramDescription><GroupInformationTable><GroupInformation groupId="%s"><GroupType xsi:type="ProgramGroupTypeType" value="otherCollection"/><BasicDescription><Title xml:lang="es" type="main">%s</Title><Synopsis xml:lang="es" length="short">%s</Synopsis><Genre href="urn:eventis:metadata:cs:GroupTypeCS:2010:serviceGroup" type="other" /><PurchaseList><PurchaseItem><Price currency="CLP">0</Price><Purchase><PurchaseType href="urn:eventis:metadata:cs:PurchaseTypeCS:2010:productCrid"><Definition>%s</Definition></PurchaseType></Purchase><Purchase><PurchaseType href="urn:eventis:metadata:cs:PropertyCS:2010:profile"><Definition>PLATFORM_EOS</Definition></PurchaseType></Purchase></PurchaseItem></PurchaseList></BasicDescription><!-- Service group to product link --><MemberOf xsi:type="MemberOfType" crid="%s"/></GroupInformation></GroupInformationTable></ProgramDescription></TVAMain>""" %(row['GroupInformation'], row['GroupTitle'], row['Synopsis'], row['PurchaseType'], row['PurchaseType']))
        f2 = open('%s.xml' % row['GroupTitle'], 'wb')
        f2.write(etree.tostring(servicegroup, xml_declaration=True, encoding="utf-8", pretty_print=True))
        f2.close()
 