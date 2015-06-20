/*:
# JSONSerialization

Natively implemented alternative to `NSJSONSerialization`. No **Foundation** required!
Work with native **Swift** types such as `Int`, `Double` and `Bool` instead of `NSNumber`.
*/

/*:
Here's some JSON in text form:
*/
let JSON = "{\"menu\": {  \"id\": \"file\",  \"value\": \"File\",  \"popup\": {    \"menuitem\": [{\"value\": \"New\", \"onclick\": \"CreateNewDoc()\"},      {\"value\": \"Open\", \"onclick\": \"OpenDoc()\"},{\"value\": \"Close\", \"onclick\": \"CloseDoc()\"}    ]  }}}"

/*:
You can open the console and see the output using `CMD + SHIFT + Y` or ⇧⌘Y.
*/
/*:
We can try to get an object from the string:
*/
var object: Any = JSONSerialization.JSONNull()
do {
    object = try JSONSerialization.decode(JSON)
    print(object)
}
catch {
    print(error)
}

/*:
We can pretty print the JSON from compatible objects:
*/
do {
    let text = try JSONSerialization.encode(object, prettyPrint: true)
    print(text)
}
catch {
    print(error)
}
