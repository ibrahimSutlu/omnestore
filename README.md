# 🛒 OmniStore

**Modern, Cloud-Native E-Commerce Infrastructure**  
*AWS · Terraform · CI/CD · Security · FinOps*

OmniStore, gerçek dünya e-ticaret senaryoları baz alınarak tasarlanmış, **güvenli, ölçeklenebilir ve maliyet odaklı** bir bulut mimarisi projesidir.  
Projenin amacı yalnızca bir uygulama çalıştırmak değil; **modern DevOps / Cloud Engineering pratiklerini uçtan uca göstermektir.**

---

## 🌐 Live Demo

🔗 **Frontend:** https://omnestore.org  
🚀 **Deployment:** GitHub Actions üzerinden otomatik

---

## 🖥️ UI Preview

> Modern e-ticaret deneyimi (statik demo – ödeme entegrasyonu yok)

![OmniStore UI](docs/images/ui.png)

---

## 🧩 Mimari Genel Bakış

![OmniStore Architecture](docs/images/architecture.jpeg)

**Trafik Akışı**


---

## 🧱 Temel Bileşenler

### ☁️ Cloud & Infrastructure
- **AWS**
- **Terraform (IaC)**
- VPC (Public / Private Subnet)
- Application Load Balancer (ALB)
- CloudFront + ACM (TLS)
- Route53 (DNS)

### 🔐 Security First Design
- Application sunucuları **private subnet**
- **Public IP yok**
- SSH erişimi yalnızca **Bastion Host** üzerinden
- Least-privilege Security Groups
- IAM role-based access

### 🚀 CI/CD
- **GitHub Actions**
- Otomatik:
  - Build
  - S3 deploy
  - CloudFront cache invalidation
- Zero-downtime frontend deployment

### 💰 FinOps Odaklı Yaklaşım
- Gereksiz kaynakların önlenmesi
- Terraform `apply / destroy` lifecycle
- Managed servisler ile operasyonel yük azaltma
- CDN ile bandwidth maliyet optimizasyonu

---

## 📂 Repository Yapısı

