$ErrorActionPreference = 'Stop'

$BASE = "http://localhost:8090/api"
$OUT = "test-results.txt"

$tests = @(
    # usuarios
    @{ Name='Usuarios - listar'; Method='GET'; Url="$BASE/alumnos"; Expected=@(200) },
    @{ Name='Usuarios - pagina'; Method='GET'; Url="$BASE/alumnos/pagina?page=0&size=5"; Expected=@(200) },
    @{ Name='Usuarios - ver inexistente'; Method='GET'; Url="$BASE/alumnos/999999"; Expected=@(404) },
    @{ Name='Usuarios - crear'; Method='POST'; Url="$BASE/alumnos"; Expected=@(201,400); Body='{"nombre":"QA","apellido":"Runner","email":"qa.runner@test.com"}' },
    @{ Name='Usuarios - filtrar'; Method='GET'; Url="$BASE/alumnos/filtrar/qa"; Expected=@(200) },
    @{ Name='Usuarios - editar inexistente'; Method='PUT'; Url="$BASE/alumnos/999999"; Expected=@(404,400); Body='{"nombre":"QA","apellido":"Runner","email":"qa.runner@test.com"}' },
    @{ Name='Usuarios - foto inexistente'; Method='GET'; Url="$BASE/alumnos/uploads/img/999999"; Expected=@(404) },
    @{ Name='Usuarios - eliminar inexistente'; Method='DELETE'; Url="$BASE/alumnos/999999"; Expected=@(204,404) },

    # examenes
    @{ Name='Examenes - listar'; Method='GET'; Url="$BASE/examenes"; Expected=@(200) },
    @{ Name='Examenes - pagina'; Method='GET'; Url="$BASE/examenes/pagina?page=0&size=5"; Expected=@(200) },
    @{ Name='Examenes - asignaturas'; Method='GET'; Url="$BASE/examenes/asignaturas"; Expected=@(200) },
    @{ Name='Examenes - filtrar'; Method='GET'; Url="$BASE/examenes/filtrar/parcial"; Expected=@(200) },
    @{ Name='Examenes - ver inexistente'; Method='GET'; Url="$BASE/examenes/999999"; Expected=@(404) },
    @{ Name='Examenes - crear invalido'; Method='POST'; Url="$BASE/examenes"; Expected=@(400); Body='{"nombre":"x","asignatura":null}' },
    @{ Name='Examenes - editar inexistente'; Method='PUT'; Url="$BASE/examenes/999999"; Expected=@(404,400); Body='{"nombre":"Parcial QA","asignatura":{"id":1},"preguntas":[]}' },
    @{ Name='Examenes - eliminar inexistente'; Method='DELETE'; Url="$BASE/examenes/999999"; Expected=@(204,404) },

    # cursos
    @{ Name='Cursos - listar'; Method='GET'; Url="$BASE/cursos"; Expected=@(200) },
    @{ Name='Cursos - pagina'; Method='GET'; Url="$BASE/cursos/pagina?page=0&size=5"; Expected=@(200) },
    @{ Name='Cursos - balanceador'; Method='GET'; Url="$BASE/cursos/balanceador-test"; Expected=@(200) },
    @{ Name='Cursos - ver inexistente'; Method='GET'; Url="$BASE/cursos/999999"; Expected=@(404) },
    @{ Name='Cursos - crear'; Method='POST'; Url="$BASE/cursos"; Expected=@(201,400); Body='{"nombre":"Curso QA"}' },
    @{ Name='Cursos - editar inexistente'; Method='PUT'; Url="$BASE/cursos/999999"; Expected=@(404,400); Body='{"nombre":"Curso QA Upd"}' },
    @{ Name='Cursos - buscar por alumno'; Method='GET'; Url="$BASE/cursos/alumno/1"; Expected=@(200) },
    @{ Name='Cursos - eliminar inexistente'; Method='DELETE'; Url="$BASE/cursos/999999"; Expected=@(204,404) },

    # respuestas (solo 3 endpoints reales)
    @{ Name='Respuestas - crear batch'; Method='POST'; Url="$BASE/respuestas"; Expected=@(201,400); Body='[{"texto":"r1","alumno":{"id":1},"pregunta":{"id":1}}]' },
    @{ Name='Respuestas - por alumno examen'; Method='GET'; Url="$BASE/respuestas/alumno/1/examen/1"; Expected=@(200) },
    @{ Name='Respuestas - examenes respondidos'; Method='GET'; Url="$BASE/respuestas/alumno/1/examenes-respondidos"; Expected=@(200) }
)

function Invoke-ApiTest {
    param($t)

    $start = Get-Date
    $status = 0
    $ok = $false
    $err = $null
    try {
        $params = @{ Method = $t.Method; Uri = $t.Url; TimeoutSec = 20; ErrorAction = 'Stop' }
        if ($t.ContainsKey('Body')) {
            $params['ContentType'] = 'application/json'
            $params['Body'] = $t.Body
        }
        $resp = Invoke-WebRequest @params
        $status = [int]$resp.StatusCode
    } catch {
        $errResp = $_.Exception.Response
        if ($errResp -and $errResp.StatusCode) {
            $status = [int]$errResp.StatusCode
        } else {
            $status = -1
            $err = $_.Exception.Message
        }
    }

    if ($t.Expected -contains $status) { $ok = $true }
    $ms = [math]::Round(((Get-Date) - $start).TotalMilliseconds, 0)
    [pscustomobject]@{
        Name = $t.Name
        Method = $t.Method
        Url = $t.Url
        Status = $status
        Expected = ($t.Expected -join ',')
        Result = $(if ($ok) { 'PASS' } else { 'FAIL' })
        Error = $err
        Ms = $ms
    }
}

$results = @()
foreach ($t in $tests) {
    $r = Invoke-ApiTest $t
    $results += $r
    $prefix = if ($r.Result -eq 'PASS') { '[PASS]' } else { '[FAIL]' }
    "$prefix $($r.Method.PadRight(6)) $($r.Status.ToString().PadRight(4)) $($r.Name)"
}

$total = $results.Count
$passed = ($results | Where-Object { $_.Result -eq 'PASS' }).Count
$failed = $total - $passed
$successRate = if ($total -gt 0) { [math]::Round(($passed / $total) * 100, 1) } else { 0 }

$lines = @()
$lines += "=============================================================="
$lines += "RESULTADOS DE PRUEBAS - cursos25_microservicios"
$lines += "=============================================================="
$lines += "Fecha: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
$lines += "Base URL: $BASE"
$lines += ""
$lines += "RESUMEN"
$lines += "- Total: $total"
$lines += "- PASS:  $passed"
$lines += "- FAIL:  $failed"
$lines += "- Exito: $successRate%"
$lines += ""
$lines += "DETALLE"
$lines += "Name | Method | Status | Expected | Result | Ms | Url"
foreach ($r in $results) {
    $lines += "$($r.Name) | $($r.Method) | $($r.Status) | $($r.Expected) | $($r.Result) | $($r.Ms) | $($r.Url)"
}

if ($failed -gt 0) {
    $lines += ""
    $lines += "FALLIDOS"
    foreach ($r in ($results | Where-Object { $_.Result -eq 'FAIL' })) {
        $lines += "- $($r.Name): status=$($r.Status), expected=$($r.Expected), url=$($r.Url), error=$($r.Error)"
    }
}

$lines -join "`r`n" | Out-File -FilePath $OUT -Encoding UTF8

""
"=============================================================="
"Total: $total | PASS: $passed | FAIL: $failed | Exito: $successRate%"
"Reporte: $OUT"
"=============================================================="
