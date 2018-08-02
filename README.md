

# Recon

Permite:

-    Recolectar correos (The harvester, infoga)
 -   Identificar subdominios (dnsrecon, fierce, ctfr)
-    Hacer un whois al dominio
-   Verificar si se puede mandar correos suplantando su dominio

## ¿COMO INSTALAR?

Testeado en Kali y ubuntu. Simplemente ejecuta:

    git clone https://github.com/DanielTorres1/recon
    bash instalar.sh

## ¿COMO USAR?

    recon.sh -d dominio.com

La herramienta creara un folder con el nombre del dominio pasado como parametro y dentro de este folder en la carpeta "reportes" donde estara el resultado del escaneo. Los archivos .csv se pueden importar a MALTEGO.
