# OmniStore

### Terraform Tabanlı Güvenli Cloud Mimari · CI/CD · FinOps Odaklı

**OmniStore**, AWS üzerinde **Terraform**, **Docker** ve **GitHub Actions** kullanılarak oluşturulmuş;  
**security-first**, **otomatik deploy edilebilir** ve **maliyet farkındalığı olan (FinOps)** bir cloud mimari projesidir.

Bu proje, gerçek dünyada karşılaşılan **altyapı, güvenlik, CI/CD ve maliyet optimizasyonu** problemlerini çözmeyi hedefler.

---

## 🚀 Mimari Genel Bakış

OmniStore aşağıdaki bileşenlerden oluşur:

- Terraform ile Infrastructure as Code (IaC)
- Public / Private subnet mimarisi
- Bastion Host üzerinden güvenli SSH erişimi
- Uygulamanın Private EC2 üzerinde çalışması
- Application Load Balancer (ALB)
- CloudFront + Route53 + ACM (HTTPS)
- GitHub Actions ile otomatik CI/CD
- Docker ile container tabanlı deployment
- Security & FinOps odaklı tasarım kararları

---

## 🧠 Temel Özellikler

- Security-first mimari (Private EC2, Bastion pattern)
- Terraform ile tekrar kurulabilir altyapı
- GitHub Actions tabanlı CI/CD pipeline
- Docker ile izole ve tutarlı deployment
- CloudFront + ALB ile performanslı erişim
- Maliyet farkındalığı (FinOps yaklaşımı)
- Gerçek prod hataları üzerinden öğrenilmiş çözüm süreci

---

## 🛠 Kullanılan Teknolojiler

| Katman | Teknoloji |
|------|----------|
| IaC | Terraform |
| Cloud Provider | AWS |
| CI/CD | GitHub Actions |
| Container | Docker |
| Load Balancer & CDN | ALB + CloudFront |
| DNS & SSL | Route53 + ACM |

---

## 🧱 Mimari Detaylar

### Network & Altyapı
- VPC içerisinde public ve private subnetler
- Public subnet’te yalnızca Bastion Host
- Private subnet’te uygulama EC2’leri
- NAT Instance ile internet çıkışı (FinOps kararı)

### Güvenlik (Security)
- Private EC2’ler public IP içermez
- SSH erişimi yalnızca Bastion üzerinden sağlanır
- ALB tek ingress noktasıdır
- Security Group’lar least-privilege mantığıyla tanımlanmıştır

### CI/CD Akışı
1. Kod GitHub’a push edilir
2. GitHub Actions pipeline tetiklenir
3. Kod Bastion Host’a kopyalanır
4. Bastion → Private EC2 senkronizasyonu yapılır
5. Docker image yeniden build edilir
6. Container otomatik olarak yeniden başlatılır

---


---

## 🚀 Kurulum & Çalıştırma

### Gereksinimler
- AWS CLI yapılandırılmış
- Terraform >= 1.5
- Docker (Bastion ve Private EC2 üzerinde)
- GitHub Secrets tanımlı

### Terraform ile Altyapıyı Kurma

```bash
terraform init
terraform apply


