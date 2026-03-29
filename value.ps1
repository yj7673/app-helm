# update-values.ps1

$Region = "ap-northeast-2"
$ValuesFile = ".\charts\myapp\values.yaml"

# host 입력 받기
$NewHost = Read-Host "새로운 host 입력 (예: www.example.com)"

# ACM에서 첫 번째 인증서 ARN 가져오기
$Arn = (aws acm list-certificates `
  --region $Region `
  --query "CertificateSummaryList[0].CertificateArn" `
  --output text).Trim()

if (-not $Arn -or $Arn -eq "None") {
  Write-Host "❌ ACM 인증서를 찾지 못했습니다." -ForegroundColor Red
  exit 1
}

# 파일 읽기
$Content = [System.IO.File]::ReadAllText($ValuesFile)

# host 변경
$Content = [regex]::Replace(
  $Content,
  '(?m)^(\s*host:\s*).*$',
  "`$1$NewHost"
)

# certificateArn 변경
$Content = [regex]::Replace(
  $Content,
  '(?m)^(\s*certificateArn:\s*).*$',
  "`$1$Arn"
)

# 파일 저장
[System.IO.File]::WriteAllText($ValuesFile, $Content)

Write-Host "values.yaml 수정 완료"
Write-Host "host: $NewHost"
Write-Host "certificateArn: $Arn"