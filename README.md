# Recon

Permite:
- Recolectar correos
- Identificar subdominios
- Hacer un whois al dominio
- Identificar perfiles de Linked-in relacionados al dominio
- Verificar si se puede mandar correos suplantando su dominio

## ¿COMO INSTALAR?

Testeado en Kali y ubuntu. Simplemente ejecuta:

`bash instalar.sh`

## ¿COMO USAR?

`recon.sh -d dominio.com`

La herramienta creara un folder con el nombre del dominio pasado como parametro y dentro de este folder en la carpeta "reports" esta el resultado del escaneo. Los archivos .csv se pueden importar a MALTEGO.
