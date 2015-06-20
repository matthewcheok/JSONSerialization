#JSONSerialization

Natively implemented alternative to `NSJSONSerialization`. No **Foundation** required!
Work with native **Swift** types such as `Int`, `Double` and `Bool` instead of `NSNumber`.

Refer to the demo project for the following example. The playground does not work in Xcode 7 Beta 1.

Here's some JSON in text form:
```
let JSON = "{\"menu\": {  \"id\": \"file\",  \"value\": \"File\",  \"popup\": {    \"menuitem\": [{\"value\": \"New\", \"onclick\": \"CreateNewDoc()\"},      {\"value\": \"Open\", \"onclick\": \"OpenDoc()\"},{\"value\": \"Close\", \"onclick\": \"CloseDoc()\"}    ]  }}}"
```

We can try to get an object from the string:

```
var object: Any = JSONSerialization.JSONNull()
do {
    object = try JSONSerialization.decode(JSON)
    print(object)
}
catch {
    print(error)
}
```

Result:
```
[menu: [id: "file", popup: [menuitem: [[onclick: "CreateNewDoc()", value: "New"], [onclick: "OpenDoc()", value: "Open"], [onclick: "CloseDoc()", value: "Close"]]], value: "File"]]
```


We can pretty print the JSON from compatible objects:

```
do {
    let text = try JSONSerialization.encode(object, prettyPrint: true)
    print(text)
}
catch {
    print(error)
}
```

Result:
```
{
   "menu": {
      "id": "file",
      "popup": {
         "menuitem": [
            {
               "onclick": "CreateNewDoc()",
               "value": "New"
            },
            {
               "onclick": "OpenDoc()",
               "value": "Open"
            },
            {
               "onclick": "CloseDoc()",
               "value": "Close"
            }
         ]
      },
      "value": "File"
   }
}
```

## License

`JSONSerialization` is under the MIT license.
