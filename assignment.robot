*** Settings ***
Library    RequestsLibrary

*** Variables ***
${BASE_URL}        http://localhost:8082
${START_ASSET_NO}  29
${START_M_NO}      1
${ROUND}           3


*** Test Cases ***

TC-003 Verify that get asset API always require valid token (Negative: ใส่ expire token จะเเสดง error)

    #-------call Post Login API to get invalid token (expire)
    Create Session    assetSession    http://localhost:8082
    ${request_body}=    Create Dictionary    username=doppio    password=weBuildBestQa
    #สร้าง token รอบเเรก
    ${resp_old}=    POST On Session    assetSession    /login    json=${request_body}    expected_status=200
    ${token_old}=    Set Variable    ${resp_old.json()['message']}
    ${request_header_old}=    Create Dictionary    token=${token_old}
    #สร้าง token รอบสอง ส่งผลให้รอบเเรก invaild เพราะ expire
    ${resp_lasted}=    POST On Session    assetSession    /login    json=${request_body}    expected_status=200
    ${token_lasted}=    Set Variable    ${resp_lasted.json()['message']}
    ${request_header_lasted}=    Create Dictionary    token=${token_lasted}

    #-------call Get asset API with invalid token (expire)
    #verfiy status code = 401
    ${get_resp}=    Get On Session    assetSession    /assets    headers=${request_header_old}      expected_status=401
    #verify status message is error
    Should Be Equal     ${get_resp.json()['status']}    error
    #verify error message = "you do not have access to this resource
    Should Be Equal     ${get_resp.json()['message']}    you do not have access to this resource
    

TC-004 Verify that create asset API can work correctly (Success: สร้างครั้งละ 1 asset)

    #-------1.call login api (POST) to get valid token
    Create Session    createAssets    http://localhost:8082
    ${request_body_login}=    Create Dictionary    username=doppio    password=weBuildBestQa
    ${resp}=    POST On Session    createAssets    /login    json=${request_body_login}    expected_status=200
    ${token}=    Set Variable    ${resp.json()['message']}
    ${request_header}=    Create Dictionary    token=${token}
    Log To console      ${request_header}

    #-------2.call create new asset api (POST) with valid token (from login api)
    #3.provide request_body about created new asset info ***ปรับไอดีห้ามซ้ำกันทุกรอบ
    ${request_body_create}=    Create Dictionary    assetId=a008    assetName=Macpro m6    assetType=1    inUse=true

    #4.verfiy status code = 200
    ${createAss_resp}=    POST On Session    createAssets    /assets      json=${request_body_create}      headers=${request_header}     expected_status=200

    #5.verify status message = success
    Should Be Equal     ${createAss_resp.json()['status']}    success

    #6.verify error message = empty
    Should Be Empty     ${createAss_resp.json()['message']}


TC-005 Verify that cannot create asset with duplicated ID (Negative: ใส่ assset ตัวซ้ำจะเเสดง error)

    #-------1.call login api (POST) to get valid token
    Create Session    createAssets    http://localhost:8082
    ${request_body_login}=    Create Dictionary    username=doppio    password=weBuildBestQa
    ${resp}=    POST On Session    createAssets    /login    json=${request_body_login}    expected_status=200
    ${token}=    Set Variable    ${resp.json()['message']}
    ${request_header}=    Create Dictionary    token=${token}
    Log To console      ${request_header}

    #-------2.call create new asset api (POST) with valid token (from login api)
    #3.input exsiting asset info
    ${request_body_create}=    Create Dictionary    assetId=a006    assetName=Macpro m987    assetType=1    inUse=true
    #4.verfiy status code = 200
    ${createAss_resp}=    POST On Session    createAssets    /assets      json=${request_body_create}      headers=${request_header}     expected_status=200
    #5.verify status message = fail
    Should Be Equal     ${createAss_resp.json()['status']}    failed
    #6.verify error message = id : a010 is already exists , please try with another id
    Should Contain    ${createAss_resp.json()['message']}    is already exists , please try with another id


TC-006 Verify that modify asset API can work correctly (Success: เเก้ไข asset info ได้)

    #-------1.call login api (POST) to get valid token
    Create Session    modifyAssets    http://localhost:8082
    ${request_body_login}=    Create Dictionary    username=doppio    password=weBuildBestQa
    ${resp}=    POST On Session    modifyAssets    /login    json=${request_body_login}    expected_status=200
    ${token}=    Set Variable    ${resp.json()['message']}
    ${request_header}=    Create Dictionary    token=${token}
    Log To console      ${request_header}

    #-------2.call create new asset api (POST) with valid token (from login api)
    ${request_body_modify}=    Create Dictionary    assetId=a001    assetName=Macpro test    assetType=1    inUse=true
    #4.verfiy status code = 200
    ${modifyAss_resp}=    PUT On Session    modifyAssets    /assets      json=${request_body_modify}      headers=${request_header}     expected_status=200
    #5.verify status message = success
    Should Be Equal     ${modifyAss_resp.json()['status']}    success
    #6.verify error message = remark: asset id will not be changed in any cases
    Should Be Equal     ${modifyAss_resp.json()['message']}     remark: asset id will not be changed in any cases

TC-007 Verify that delete asset API can work correctly (Success: ลบ asset info ได้)

    #-------1.call login api (POST) to get valid token
    Create Session    deleAssets    http://localhost:8082
    ${request_body_login}=    Create Dictionary    username=doppio    password=weBuildBestQa
    ${resp}=    POST On Session    deleAssets    /login    json=${request_body_login}    expected_status=200
    ${token}=    Set Variable    ${resp.json()['message']}
    ${request_header}=    Create Dictionary    token=${token}
    Log To console      ${request_header}

    #-------2.call create new asset api (POST) with valid token (from login api)
    #4.verfiy status code = 200
    ${deleAss_resp}=    DELETE On Session    deleAssets    /assets/a033      headers=${request_header}     expected_status=200
    #5.verify status message = success
    Should Be Equal     ${deleAss_resp.json()['status']}    success
    #6.verify error message = empty
    Should Be Empty     ${deleAss_resp.json()['message']}

#=====================================================END Assignment==========================================================

TC-008 Verify that get asset API always require valid token (by input empty token)

    #-------สร้างตัวเเปรไว้เก็บ token=empty
    ${request_header}=    Create Dictionary    token=

    #-------call Get asset API with invalid token (expire)
    #กรณี headers={'token': ''} จากนั้น verfiy status code = 401
    ${get_resp}=    Get On Session    assetSession    /assets    headers=${request_header}      expected_status=401
    #verify status message is error
    Should Be Equal     ${get_resp.json()['status']}    error
    #verify error message = "you do not have access to this resource
    Should Be Equal     ${get_resp.json()['message']}    you do not have access to this resource


TC-009 Verify that create asset API can work correctly (สร้าง asset ใหม่ โดยห้ามซ้ำของเดิม หากเจอซ้ำให้หยุดทำงาน)

    #-------1.call login api (POST) to get valid token
    Create Session    mainSession    http://localhost:8082
    ${request_body_login}=    Create Dictionary    username=doppio    password=weBuildBestQa
    ${resp}=    POST On Session    mainSession    /login    json=${request_body_login}    expected_status=200
    ${token}=    Set Variable    ${resp.json()['message']}
    ${request_header}=    Create Dictionary    token=${token}
    Log To console      ${request_header}

    #-------2.call (Get) API to get asset with token & verfiy status code = 200
    ${get_resp}=    Get On Session    mainSession    /assets    headers=${request_header}       expected_status=200
    #สร้าง list ของ assetId ทั้งหมดจาก response โดยวนเอาเฉพาะ value ของเเต่ละ assetId มาเก็บใส่ ${existing_ids} ทั้งหมด
    ${existing_ids}=    Evaluate    [a['assetId'] for a in $get_resp.json()]

    #-------3.call create new asset api (POST) with valid token (from login api)
    ${request_body_create}=    Create Dictionary    assetId=a033    assetName=Macpro m009    assetType=1    inUse=true
    #เอา assetId ที่จะสร้างออกมาจาก request_body_create (Dict type) การเข้าถึงต้องใช้: ${dict['key']}
    ${new_id}=    Set Variable    ${request_body_create['assetId']}

    #เเสดง exsiting asset เเละ new asset ที่จะสร้างออกมาดู
    Log To Console    ===== Duplicate Check =====
    Log To Console    existing_ids = ${existing_ids}
    Log To Console    new_id = ${new_id}

    #-------4.เช็คว่า new_id อยู่ใน existing_ids ไหม
    #Evaluate = คำนวณ expression แบบ Python แล้วคืนค่า
    #is_dup เก็บ True ถ้า 'a010' อยู่ใน ['a001','a002','a010'] >> เจอซ้ำ
    #is_dup เก็บ False ถ้า 'a099' ไม่อยู่ใน ['a001','a002','a010'] >> ไม่เจอซ้ำ
    ${is_dup}=    Evaluate    $new_id in $existing_ids

    #-------5.เงื่อนไข if (True) เเละ  else (False)
    IF  ${is_dup}
        #ถ้าเจอซ้ำให้หยุดทำงานทันที ไม่ไป else ต่อ
        Pass Execution    Checking result = ❌ System found duplicate asset_id → skip create
    ELSE
        Log To Console    Checking result = ✅ System not found duplicate asset_id → creating new asset soon.
        ${create_resp}=    POST On Session
        ...    mainSession
        ...    /assets
        ...    json=${request_body_create}
        ...    headers=${request_header}
        ...    expected_status=200
        Should Be Equal    ${create_resp.json()['status']}    success
    END

TC-0010 Verify that create asset API can work correctly (สร้าง asset ใหม่ โดยห้ามซ้ำของเดิม หากเจอซ้ำให้ generate asset info ใหม่เอง)

    #-------1.call login api (POST) to get valid token
    Create Session    mainSession    http://localhost:8082
    ${request_body_login}=    Create Dictionary    username=doppio    password=weBuildBestQa
    ${resp}=    POST On Session    mainSession    /login    json=${request_body_login}    expected_status=200
    ${token}=    Set Variable    ${resp.json()['message']}
    ${request_header}=    Create Dictionary    token=${token}
    Log To console      ${request_header}

    #-------2.call (Get) API to get asset with token & verfiy status code = 200
    ${get_resp}=    Get On Session    mainSession    /assets    headers=${request_header}       expected_status=200
    #สร้าง list ของ assetId ทั้งหมดจาก response โดยวนเอาเฉพาะ value ของเเต่ละ assetId มาเก็บใส่ ${existing_ids} ทั้งหมด
    ${existing_ids}=    Evaluate    [a['assetId'] for a in $get_resp.json()]

    #-------3.call create new asset api (POST) with valid token (from login api)
    ${request_body_create}=    Create Dictionary    assetId=a036    assetName=Macpro m009    assetType=1    inUse=true
    #เอา assetId ที่จะสร้างออกมาจาก request_body_create (Dict type) การเข้าถึงต้องใช้: ${dict['key']}
    ${new_id}=    Set Variable    ${request_body_create['assetId']}

    #เเสดง exsiting asset เเละ new asset ที่จะสร้างออกมาดู
    Log To Console    ===== Duplicate Check =====
    Log To Console    existing_ids = ${existing_ids}
    Log To Console    new_id = ${new_id}

    #-------4.เช็คว่า new_id อยู่ใน existing_ids ไหม
    #Evaluate = คำนวณ expression แบบ Python แล้วคืนค่า
    #is_dup เก็บ True ถ้า 'a010' อยู่ใน ['a001','a002','a010'] >> เจอซ้ำ
    #is_dup เก็บ False ถ้า 'a099' ไม่อยู่ใน ['a001','a002','a010'] >> ไม่เจอซ้ำ
    ${is_dup}=    Evaluate    $new_id in $existing_ids

    #-------5.เงื่อนไข if (True) เเละ  else (False)
    #ถ้าเจอซ้ำให้สร้างอันใหม่ที่ generate เอง ไม่ไป else ต่อ
    IF  ${is_dup}

        #ถ้าเจอซ้ำให้สร้างอันใหม่ที่ generate เอง ไม่ไป else ต่อ
        Log To Console    Checking result = ❗ System found duplicate asset_id (${new_id}) → auto-generate a new one

        # 1) หาเลขตัวล่าสุดจาก existing_ids (เฉพาะที่ขึ้นต้นด้วย a และตามด้วยตัวเลข)
        ${max_no}=    Evaluate
        ...    max([int(x[1:]) for x in $existing_ids if x.startswith('a') and x[1:].isdigit()])

        # 2) สร้างเลขถัดไป + format เป็น aNNN
        ${next_no}=     Evaluate    ${max_no} + 1
        ${new_assetId}=     Evaluate    f"a{${next_no}:03d}"

        # 3) สร้าง assetName ให้ขึ้นต้นด้วย Huawai
        ${new_assetName}=    Set Variable    Huawai Model-${next_no}

        # 4) สร้าง request body ตามเงื่อนไข (assetType=5, inUse=true)
        &{auto_body}=    Create Dictionary
        ...    assetId=${new_assetId}
        ...    assetName=${new_assetName}
        ...    assetType=5
        ...    inUse=${True}

        Log To Console    ✅ Auto Create Body = ${auto_body}

        # 5) POST create 1 ตัว
        ${create_resp}=    POST On Session    mainSession    /assets
        ...    json=&{auto_body}
        ...    headers=${request_header}
        ...    expected_status=200

        Should Be Equal    ${create_resp.json()['status']}    success

        # 6) แสดง asset info ที่เพิ่งสร้างสำเร็จ (จาก body ที่ส่ง)
        Log To Console    🎉 Created asset info = ${auto_body}

        # 7) ดึง current asset list อีกครั้งเพื่อสรุป
        ${final_get}=    Get On Session    mainSession    /assets    headers=${request_header}    expected_status=200
        ${final_count}=  Get Length    ${final_get.json()}

        ${assets}=    Set Variable    ${final_get.json()}
        Log To Console    ===== Current Asset List (count=${final_count}) =====
        FOR    ${a}    IN    @{assets}
            Log To Console    - ${a['assetId']} | ${a['assetName']} | ${a['assetType']} | ${a['inUse']}
        END

        Pass Execution    ✅ Duplicate handled: auto-created ${new_assetId} and printed current list

    #ถ้าเจอไม่ซ้ำให้สร้างอันที่ใส่ body ไว้    
    ELSE
        Log To Console    Checking result = ✅ System not found duplicate asset_id → creating new asset soon.
        ${create_resp}=    POST On Session
        ...    mainSession
        ...    /assets
        ...    json=${request_body_create}
        ...    headers=${request_header}
        ...    expected_status=200
        Should Be Equal    ${create_resp.json()['status']}    success
    END


TC-011 Verify that delete asset API can work correctly (ลบเเล้วกลับไปตรวจค่าเส้น get ต้องไม่เจอ)

    #-------1.call login api (POST) to get valid token
    Create Session    deleAssets    http://localhost:8082
    ${request_body_login}=    Create Dictionary    username=doppio    password=weBuildBestQa
    ${resp}=    POST On Session    deleAssets    /login    json=${request_body_login}    expected_status=200
    ${token}=    Set Variable    ${resp.json()['message']}
    ${request_header}=    Create Dictionary    token=${token}
    Log To console      ${request_header}

    #-------2.call deleted asset api (Delete) with valid token (from login api)
    ${request_body_dele}=    Create Dictionary    assetId=a003
    #เอา assetId ที่จะลบออกมาจาก request_body (Dict type)
    ${dele_id}=    Set Variable    ${request_body_dele['assetId']}
    Log To console      asset_id plan to deleting = ${dele_id}
    #4.ทำการลบจริง เเละ verfiy status code = 200
    ${deleAss_resp}=    DELETE On Session    deleAssets    /assets/${dele_id}      headers=${request_header}     expected_status=200
    #5.verify status message = success
    Should Be Equal     ${deleAss_resp.json()['status']}    success
    #6.verify error message = empty
    Should Be Empty     ${deleAss_resp.json()['message']}

    #-------3.call (Get) API to get asset เพื่อตรวจว่า asset list หายไปจากเส้น get จริงไหม
    ${get_resp}=    Get On Session    deleAssets    /assets    headers=${request_header}       expected_status=200
    #สร้าง list ของ assetId ทั้งหมดจาก response โดยวนเอาเฉพาะ value ของเเต่ละ assetId มาเก็บใส่ ${existing_ids} ทั้งหมด
    ${existing_ids}=    Evaluate    [a['assetId'] for a in $get_resp.json()]

    #เเสดง exsiting asset เเละ dele asset ที่จะค้นหาออกมาดูก่อนเริ่ม
    Log To Console    ===== Deleted Checklist =====
    Log To Console    existing_ids = ${existing_ids}
    Log To Console    already deleted_id = ${dele_id}

    #-------4.เช็คว่า ${dele_id} อยู่ใน existing_ids ไหม
    ${is_dele}=    Evaluate    $dele_id in $existing_ids

    #-------5.เงื่อนไข if (True) เเละ  else (False)
    IF  ${is_dele}
        #ถ้าเจอ asset ที่ลบไปเเล้ว ให้หยุดทำงานทันที เเสดง error msg ตี fail test
        Fail    Checking result = ❌ ระบบยังเจอ asset_id เพราะไม่ถูกลบจริง
    ELSE
        #ถ้าไม่เจอ asset ที่ลบ เเสดงข้อความเเล้วจบ
        Pass Execution    Checking result = ✅ ระบบไม่พบ asset_id ที่ลบเเล้ว เก่งมาก
    END



#TC-00 Verify that can't modify asset API with missing assetID

#ให้ AI สอนทำโจทย์ยาก
