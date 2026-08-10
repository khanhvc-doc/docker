# Mô hình có dạng (HTTP)

```bash
Internet
   |
Firewall: TCP 80
   |
Nginx Docker trong DMZ
   |
   ├── pit.hansollvina.com     → PIT-IP:843
   ├── sims.hansollvina.com    → SIMS-IP:8888
   ├── subcon.hansollvina.com  → SUBCON-IP:8008
   ├── yte.hansollvina.com     → YTE-IP:8008
   └── hr.hansollvina.com      → HR-IP:PORT/đường-dẫn
```

[text](<Readme PHASE 1 HTTP.md>)

# Tương tự cho HTTPs
[text](<Readme PHASE 2 HTTPs.md>)

# Xin 1 CA dùng nhiều domain thông qua Expand
[text](<Readme PHASE 3 HTTPs-expand CA.md>)

# Xin lại CA
[text](<Readme PHASE 4-Renew CA.md>)

# Khi người dùng truy cập vào http tự động chuyển qua httpS
[text](<Readme PHASE 5-Redirect HTTPs.md>)
