import os
import time
import subprocess
from pathlib import Path

# --- FUNCIONES DE AYUDA ---
def leer_archivo(ruta, por_defecto=""):
    archivo = Path(ruta)
    if archivo.exists():
        return archivo.read_text().strip()
    return por_defecto

# --- RUTAS DE CONFIGURACIÓN ---
# Usamos Path para que Windows entienda bien las rutas
URL_FILE    = Path("data/url.dat")
DIR_FILE    = Path("data/dir.dat")
WAIT_FILE   = Path("data/wait.dat")
STOP_FILE   = Path("events/stop.now")

def descargar():
    # 1. Leer configuración en cada ciclo por si cambia
    url = leer_archivo(URL_FILE)
    carpeta_destino = leer_archivo(DIR_FILE, "AutoDJ")
    
    if not url:
        print("⚠️ No hay URL en data/url.dat. Esperando...")
        return

    # Crear carpeta si no existe
    Path(carpeta_destino).mkdir(parents=True, exist_ok=True)

    print(f"\n>>> Revisando lista: {url}")
    print(f">>> Destino: {carpeta_destino}")

    # 2. Comando yt-dlp
    comando = [
        "yt-dlp",
        "--extract-audio",
        "--audio-format", "mp3",
        "--audio-quality", "0",
        "--download-archive", str(Path(carpeta_destino) / "historial.txt"),
        "-o", f"{carpeta_destino}/%(title)s.%(ext)s",
        "--no-warnings",
        url
    ]
    
    subprocess.run(comando)

# --- BUCLE PRINCIPAL ---
print("💿 AutoDJPlaylist.")

while True:
    # 3. Comprobar si existe el archivo de parada
    if STOP_FILE.exists():
        print(f"\n🛑 Archivo {STOP_FILE} detectado. Deteniendo sistema...")
        # Opcional: borrar el archivo stop para que esté listo para la próxima vez
        # STOP_FILE.unlink() 
        break

    descargar()

    # 4. Leer el tiempo de espera
    try:
        segundos_espera = int(leer_archivo(WAIT_FILE, "60"))
    except ValueError:
        segundos_espera = 30 # Por seguridad si el archivo tiene texto raro

    print(f"\n[ESPERA] Próxima revisión en {segundos_espera} segundos...")
    time.sleep(segundos_espera)
    os.system('cls' if os.name == 'nt' else 'clear')
    print("💿 AutoDJPlaylist.")