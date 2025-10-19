A small, reproducible example that provisions an Ubuntu 22.04 EC2 instance with Terraform and configures it at first boot using cloud‑init to install Nginx and serve a simple HTML page. The goal is reliability and clarity: the same result every time, with minimal moving parts.

---

What I learned building a tiny, repeatable server on AWS. If this helps you, awesome. If you’d do something differently, I’d love to hear it.

---

Why I built this

I wanted a clean, repeatable way to bring up a server without clicking around or SSH’ing to set things up. The target: one command to create it, one command to remove it, and a small check to prove it works.

---

What this project does

Provisions an Ubuntu 22.04 EC2 instance with Terraform (default VPC).

Uses cloud‑init on first boot to:

update packages

install Nginx

write a simple HTML page

expose a /healthz endpoint

Opens HTTP (80) to the world and optional SSH (22) from my IP only (/32).

Prints outputs: public IP, public DNS, and a convenient http_url.

---

# How to Run
```
terraform init
terraform validate
terraform apply -auto-approve
```
# Tear Down
```
terraform destroy -auto-approve
```

# Quick checks 
curl -i http://<your.IP>  
curl -s http://<your.IP>/healthz

# Check if SSH is enabled
```
sudo cloud-init status --long
sudo tail -n 50 /var/log/cloud-init-output.log
systemctl status nginx
```

File structure:
```
auto-provision-ec2/
├── main.tf
├── variables.tf
├── outputs.tf
├── cloud-init.yaml
├── index.html.tftpl
└── terraform.tfvars.example
```

Real uses:

- Launch a short‑lived server to try an idea. 
- Tear it down when you’re done.
- Make sure your startup script works before baking a golden AMI.
- Quick “is it up?” check at /healthz.
- Build the habit: delete and recreate instead of hand‑fixing a broken box.

Extra:
If you'd like to see more on the project internally check out my blog post on it and let me know what you'd add to the project or change, ciao 👋
