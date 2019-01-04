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

with open('vtr_prodList.csv') as f:
    reader = csv.DictReader(f, delimiter=';')
    for row in reader:
        print row['allowReplayTV']
        if row['allowReplayTV'] == 'true':
            productbody = etree.fromstring("""<TVAMain xml:lang="es" xmlns="urn:tva:metadata:2010" xmlns:mpeg7="urn:tva:mpeg7:2008" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="urn:tva:metadata:2010 http://www.broadcastingdata.com/dataimport/tva/tva1.6/tva_metadata_3-1_v161.xsd"><ProgramDescription><GroupInformationTable><GroupInformation groupId="%s"><GroupType xsi:type="ProgramGroupTypeType" value="otherCollection"/><BasicDescription><Title xml:lang="es" type="main">%s</Title><Synopsis xml:lang="es" length="short">%s</Synopsis><Genre type="other" href="urn:eventis:metadata:cs:GroupTypeCS:2010:product"/><PurchaseList><PurchaseItem><Price currency="CLP">0</Price><Purchase><PurchaseType href="urn:eventis:metadata:cs:PurchaseTypeCS:2010:opportunity.subscription"><Name xml:lang="es">%s</Name></PurchaseType></Purchase></PurchaseItem></PurchaseList></BasicDescription><OtherIdentifier type="EdsProductId" organization="eventis" authority="eventis">%s</OtherIdentifier><OtherIdentifier type="SUBSCRIPTION_PACKAGE_ID" organization="eventis" authority="eventis">%s</OtherIdentifier><OtherIdentifier type="TstvProps" organization="eventis" authority="eventis">{"replayDuration": %s, "allowReplayTV": %s, "allowStartOver": %s, "isVosdal": %s}</OtherIdentifier></GroupInformation></GroupInformationTable></ProgramDescription></TVAMain>""" % (row['PurchaseType'], row['ProductTitle'], row['Synopsis'], row['OfferTitle'], row['EdsProductId'], row['billingID'], row['replayDuration'], row['allowReplayTV'], row['allowStartOver'], row['isVosdal']))
        else:
            productbody = etree.fromstring("""<TVAMain xml:lang="es" xmlns="urn:tva:metadata:2010" xmlns:mpeg7="urn:tva:mpeg7:2008" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="urn:tva:metadata:2010 http://www.broadcastingdata.com/dataimport/tva/tva1.6/tva_metadata_3-1_v161.xsd"><ProgramDescription><GroupInformationTable><GroupInformation groupId="%s"><GroupType xsi:type="ProgramGroupTypeType" value="otherCollection"/><BasicDescription><Title xml:lang="es" type="main">%s</Title><Synopsis xml:lang="es" length="short">%s</Synopsis><Genre type="other" href="urn:eventis:metadata:cs:GroupTypeCS:2010:product"/><PurchaseList><PurchaseItem><Price currency="CLP">0</Price><Purchase><PurchaseType href="urn:eventis:metadata:cs:PurchaseTypeCS:2010:opportunity.subscription"><Name xml:lang="es">%s</Name></PurchaseType></Purchase></PurchaseItem></PurchaseList></BasicDescription><OtherIdentifier type="EdsProductId" organization="eventis" authority="eventis">%s</OtherIdentifier></GroupInformation></GroupInformationTable></ProgramDescription></TVAMain> """ % (row['PurchaseType'], row['ProductTitle'], row['Synopsis'], row['OfferTitle'], row['EdsProductId']))
        f1 = open('%s.xml' % row['ProductTitle'], 'wb')
        f1.write(etree.tostring(productbody, xml_declaration=True, encoding="utf-8", pretty_print=True))
        f1.close()
