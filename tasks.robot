*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.
Library           RPA.Browser    
Library           RPA.HTTP
Library           RPA.Tables
Library           RPA.core.notebook
Library           OperatingSystem
Library           RPA.PDF
Library           RPA.Archive
Library           RPA.Robocloud.Secrets
Library           myfunction.py

*** Keywords ***
Open the robot order website
    ${url}=    Get Secret    website
    Open Available Browser      ${url}[url]
    Maximize Browser Window


*** Keywords ***
Get orders
    Create Directory    ${CURDIR}${/}Data
    Download    https://robotsparebinindustries.com/orders.csv      target_file=${CURDIR}${/}Data   overwrite=True
    ${csv_data}     Read table from CSV     Data/orders.csv     header=True
    Return From Keyword     ${csv_data}

*** Keywords ***
Close the annoying modal
    Click Element If Visible    //button[contains(.,"OK")]

*** Keywords ***
Fill the form
    [Arguments]    ${row}
    Select From List By Value  //select[@id="head"]     ${row}[Head]
    Click Element If Visible  id-body-${row}[Body]
    Input Text    //input[@placeholder="Enter the part number for the legs"]    ${row}[Legs]
    Input Text    //input[@name="address"]    ${row}[Address]

*** Keywords ****
Place Order
    Click Button When Visible    //button[@id="preview"]
    Click Button When Visible    //button[@id="order"]
    Wait Until Page Contains Element   id:order-another

*** Keywords ***
Reciept To Pdf
    [Arguments]   ${order}
    Wait Until Page Contains Element   id:order-another
    ${html_reciept}=     Get Element Attribute    id:receipt    outerHTML
    Html To Pdf   ${html_reciept}   ${CURDIR}${/}output${/}${order}[Order number].pdf
    Screenshot    id:robot-preview-image    ${CURDIR}${/}output${/}${order}[Order number].png
    ${openpdf}=  Open Pdf  ${CURDIR}${/}output${/}${order}[Order number].pdf
    Add Watermark Image To Pdf  ${CURDIR}${/}output${/}${order}[Order number].png  ${CURDIR}${/}output${/}${order}[Order number].pdf  ${CURDIR}${/}output${/}${order}[Order number].pdf
    Close Pdf  ${openpdf}
    Click Button When Visible    //button[@id="order-another"]

*** Keywords ***
Archive the receipts
    Archive Folder With Zip   ${CURDIR}${/}output  receipts.zip

*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    ${out_dict}    Create Task    Order robots from RobotSpareBin Industries Inc
    Log   ${out_dict}
    Open the robot order website
    Task Log    ${out_dict}    Test Log
    Task Status Update    ${out_dict}    Status Update
    #Orch Log    Order robots from RobotSpareBin Industries Inc    pass    Task1 details
    


*** Tasks ***
Test 1
    ${out_dict}    Create Task    Test 1
    ${orders}=    Get orders
    FOR    ${row}    IN    @{orders}
        Close the annoying modal
        Fill the form    ${row}
        Wait Until Keyword Succeeds   10x   .5sec   Place Order
        Task Log    ${out_dict}     Order Placed for Order number ${row}[Order number]
        #Orch Log    Test 1    pass    Order Placed for Order number ${row}[Order number] 
        Reciept To Pdf    ${row}
        #Orch Log    Test 1    pass    pdf generated for Order number ${row}[Order number] 
    END
    Task Log    ${out_dict}    Test Log
    Task Status Update    ${out_dict}    Status Update
    #Orch Log    Test 1    pass    Task2 details

Test 2
    ${out_dict}    Create Task    Test 2
    Close Browser
    Task Log    ${out_dict}    Test Log
    Task Status Update    ${out_dict}    Status Update
    #Orch Log    Test 2    pass    Task3 details

Test3
    ${out_dict}    Create Task    Test3
    Archive the receipts
    Log    Done.
    Task Log    ${out_dict}    Test Log
    Task Status Update    ${out_dict}    Status Update
    #Orch Log    Test3    pass    Task4 details
