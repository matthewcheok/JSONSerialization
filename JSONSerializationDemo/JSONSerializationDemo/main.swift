//
//  main.swift
//  JSONSerializationDemo
//
//  Created by Matthew Cheok on 20/6/15.
//  Copyright © 2015 matthewcheok. All rights reserved.
//

let JSON = "{\"menu\": {  \"id\": \"file\",  \"value\": \"File\",  \"popup\": {    \"menuitem\": [{\"value\": \"New\", \"onclick\": \"CreateNewDoc()\"},      {\"value\": \"Open\", \"onclick\": \"OpenDoc()\"},{\"value\": \"Close\", \"onclick\": \"CloseDoc()\"}    ]  }}}"

var object: Any = JSONSerialization.JSONNull()
do {
    object = try JSONSerialization.decode(JSON)
    print(object)
}
catch {
    print(error)
}

do {
    let text = try JSONSerialization.encode(object, prettyPrint: true)
    print(text)
}
catch {
    print(error)
}