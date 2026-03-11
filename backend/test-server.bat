@echo off
echo === Test HAPI FHIR Server ===
echo.
echo [1] Testing metadata endpoint...
curl -s -X GET http://localhost:8080/fhir/metadata --output NUL --write-out "HTTP Status: %%{http_code}\n"
echo.
echo [2] Creating a test patient...
curl -X POST http://localhost:8080/fhir/Patient ^
  -H "Content-Type: application/fhir+json" ^
  -d "{\"resourceType\":\"Patient\",\"name\":[{\"family\":\"Perez\",\"given\":[\"Juan\"]}],\"gender\":\"male\",\"birthDate\":\"1990-01-15\"}" ^
  -s -o patient_response.json -w "HTTP Status: %%{http_code}\n"
echo.
echo [3] Searching for patients...
curl -s -X GET http://localhost:8080/fhir/Patient --output search_response.json --write-out "HTTP Status: %%{http_code}\n"
echo.
echo === Tests completed ===
echo Check patient_response.json and search_response.json for details
pause
