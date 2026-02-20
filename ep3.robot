*** Settings ***
Library    RequestsLibrary


*** Test Cases ***

TC-001A [Login API] Verify when input wrong username or password, API should return error
    #call API with wrong username>>>done
    Create Session    loginSession    http://localhost:8082
    ${request_body}=    Create Dictionary    username=doppio222    password=12345
    #verify status code is 401>>>done
    ${resp}=    POST On Session    loginSession    /login    json=${request_body}    expected_status=401
    #verify status message is error>>>done
    Should Be Equal     ${resp.json()['status']}    error
    #verify error message is invalid username or password>>>done
    Should Be Equal     ${resp.json()['message']}    invalid username or password

TC-001B [Login API] Verify when input correct username or password, API should return success
    #call API with wrong username>>>done
    Create Session    loginSession    http://localhost:8082
    ${request_body}=    Create Dictionary    username=doppio    password=weBuildBestQa
    #verify status code is 200>>>done
    ${resp}=    POST On Session    loginSession    /login    json=${request_body}    expected_status=200
    #verify status message is success>>>done
    Should Be Equal     ${resp.json()['status']}    success
    #verify success message is return token>>>done
    Should Not Be Empty     ${resp.json()['message']}

TC-002 [Get Asset API] Verify That Can Get Asset List From Get API correctly

    #-------call Post API to login and get token
    Create Session    assetSession    http://localhost:8082
    ${request_body}=    Create Dictionary    username=doppio    password=weBuildBestQa
    #POST On Session keyword คืนค่า object ทั้งก้อน (status_code,headers,body ที่เปง json) กลับมาใส่ ${resp}
    ${resp}=    POST On Session    assetSession    /login    json=${request_body}    expected_status=200
    #Set vari keyword เอาเฉพาะ value ของ ${resp.json()['message']} ที่มีอยู่แล้วมา copy/assign ใส่ตัวเเปร ${token} อีกที
    ${token}=    Set Variable    ${resp.json()['message']}
    #Create header (Dict type) เพื่อเก็บค่า {'token': 'P25yynB-0GHx9-vbXmMzzgsQeRf2wLHh'}
    ${request_header}=    Create Dictionary    token=${token}

    #-------call Get API to get asset with token & verfiy status code = 200
    #call get method ที่ไม่ต้องมี requestBody, ไม่ต้องเขียน expectStatus=200 (Default ตรวจ 200 อยุเเล้ว) เส้นนี้ต้องมี header(token) ด้วย
    #Step นี้จะเก็บ headers={'token': 'xFyMfW0e28jjVqMOmAF53yYdYRf8R6uY'} เเล้ว
    ${get_resp}=    Get On Session    assetSession    /assets    headers=${request_header}

    #-------check response contains at least 1 assets
    #ในการตรวจสอบจำนวน ให้ใช้ get lenght ได้ในกรณีที่ข้อมูลเป็น array list
    ${count}=   Get length  ${get_resp.json()}
    #ใช้ฟังก์ชั่น evaluate (เรียกใช้คำสั่ง python ภายใต้ robot) ตรวจสอบว่าค่าที่ได้ มากกว่า 0 ไหม (มากกว่า return "True", ไม่มากกว่า return "False" เก็บในตัวเเปร)
    ${morethanone}=     evaluate    ${count}>0
    #ตรวจว่าค่าใน ${morethanone} เท่ากับ String "True" จิงไหม
    Should be True      ${morethanone}
