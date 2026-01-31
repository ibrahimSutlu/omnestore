# 🛒 OmneStore

**Modern, Cloud-Native E-Commerce Infrastructure**  
*AWS · Terraform · CI/CD · Security · FinOps*

Proje kapsamında altyapıyı Terraform kullanarak kod ile kurdum. Uygulamayı satın aldığım alan adı (domain) üzerinden yayınladım ve alan adı yönlendirmelerini Route53 ile yapılandırdım. Siteyi HTTPS üzerinden güvenli hale getirerek kullanıcıların erişimine açtım. İçeriklerin hızlı ve verimli sunulması için CloudFront kullandım.

Ayrıca bu projede;

Açık ve kapalı ağ yapısını ayırarak güvenli bir ağ tasarımı oluşturdum

Sunucuları genel IP olmadan kapalı ağda çalıştırdım

Kod güncellemelerini otomatik dağıtım süreci ile yönettim

Gereksiz kaynak kullanımını önleyerek temel maliyet kontrolü sağladım

OmniStore ile amacım; bir stajyer olarak bulut altyapısı kurma, alan adı bağlama, güvenli yayın yapma ve otomatik dağıtım süreçlerini uçtan uca uygulayabildiğimi somut bir proje üzerinden göstermektir.

---

## 🌐 Live Demo

🔗 **Frontend:** https://omnestore.org  
🚀 **Deployment:** GitHub Actions üzerinden otomatik

---

## 🖥️ UI Preview

> Modern e-ticaret deneyimi (statik demo – ödeme entegrasyonu yok)

![OmniStore UI](docs/images/ui.png)

---

## 🏗️ AWS Architecture Overview

![OmniStore UI](docs/images/diagram.png)

## 🧱 Temel Bileşenler

### ☁️ Bulut ve Altyapı
- Sistem AWS üzerinde çalışmaktadır
- Altyapı Terraform ile kod olarak tanımlanmıştır
- Sanal ağ (VPC) yapısı:
  - Açık ağ (Public Subnet)
    - Yük dengeleyici (ALB)
    - Bastion sunucusu
  - Kapalı ağ (Private Subnet)
    - Uygulama sunucuları
- Yük dengeleyici (ALB)
  - Gelen istekleri uygulama sunucularına yönlendirir
  - HTTP isteklerini HTTPS’e çevirir
- CloudFront
  - İçerikleri kullanıcılara en yakın noktadan sunar
- ACM
  - HTTPS için güvenlik sertifikası sağlar
- Route53
  - Alan adı ve yönlendirme işlemlerini yönetir

---

## 🔐 Güvenlik Yapısı
- Uygulama sunucuları yalnızca kapalı ağda çalışır
- Sunucuların genel IP adresi yoktur
- Sunuculara erişim:
  - Sadece Bastion sunucusu üzerinden yapılır
- Güvenlik kuralları:
  - Yalnızca gerekli portlar açıktır
  - Sunucular birbiriyle sınırlı şekilde iletişim kurar
- Yetkilendirme:
  - Erişimler rol bazlı tanımlanmıştır
  - Gizli bilgiler kod içinde tutulmaz

---

## 🚀 Otomatik Dağıtım Süreci
- Kod gönderimleri GitHub Actions ile otomatik olarak işlenir
- Her güncellemede:
  - Proje derlenir
  - Dosyalar S3 üzerine yüklenir
  - CloudFront önbelleği temizlenir
- Güncelleme sırasında:
  - Kullanıcı tarafında kesinti yaşanmaz
- Gerekli durumlarda:
  - Bastion üzerinden sunuculara bakım yapılabilir

---

## 💰 Maliyet Yönetimi
- Gereksiz kaynak kullanımı önlenmiştir
- Tüm altyapı Terraform ile yönetildiği için:
  - Kolayca kurulup kaldırılabilir
- Hazır servisler kullanılarak:
  - Yönetim yükü azaltılmıştır
- CloudFront sayesinde:
  - İnternet trafiği maliyeti düşürülür
  - Sunucu üzerindeki yük azaltılır
- Deneme ve canlı ortamlar:
  - Ayrı ayrı kontrol edilebilir
---

## 📂 Repository Yapısı
```text
omnistore/
├── .github/
│   └── workflows/
│       └── deploy.yml          # Frontend CI/CD (GitHub Actions → S3)
│
├── docs/
│   ├── iam/                    # IAM policy & role dokümantasyonu
│   └── s3/                     # S3 AMP policy & role örnekleri
│
├── infra/                      # Terraform Infrastructure
│   ├── backend.tf              # S3 + DynamoDB state backend
│   ├── main.tf                 # Ana infrastructure tanımı
│   ├── variables.tf            # Input değişkenleri
│   ├── outputs.tf              # Terraform output’ları
│   ├── terraform.tfvars        # Ortam bazlı değişkenler (secret içermez)
│   └── modules/
│       ├── vpc/                # VPC, Subnet, Route Table
│       ├── security/           # Security Group & IAM modülleri
│       └── compute/            # EC2, ALB ve ilgili kaynaklar
│
├── omnistore-ui/               # Frontend (React)
│   ├── src/                    # React source code
│   ├── public/                 # Static assets
│   ├── dist/                   # Build çıktısı
│   ├── Dockerfile              # Frontend containerization
│   └── nginx/                  # Opsiyonel reverse proxy / ingress config
│
├── .gitignore                  # Gereksiz dosyalar
└── README.md                   # Proje dokümantasyonu
``` 

## 📜 Lisans
Bu proje MIT Lisansı ile lisanslanmıştır.
