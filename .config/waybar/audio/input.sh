#!/bin/bash

# Verificar se o Rofi está em execução
if pgrep -x "rofi" > /dev/null; then
    # Se o Rofi estiver em execução, fechá-lo
    pkill rofi
else
    # Listar dispositivos de áudio de entrada (sources)
    devices=$(pactl list sources | awk '/Name:/ {print $2}')

    # Obter o dispositivo de entrada padrão
    default_device=$(pactl info | grep "Default Source" | awk -F': ' '{print $2}')

    # Adicionar o marcador de qual dispositivo está em "default"
    devices_with_marker=""
    for device in $devices; do
      if [ "$device" == "$default_device" ]; then
        devices_with_marker+="$device (default)\n"
      else
        devices_with_marker+="$device\n"
      fi
    done

    # Garantir que o Rofi só receba entradas válidas (remover entradas vazias)
    devices_with_marker=$(echo -e "$devices_with_marker" | grep -v '^$')

    # Usar Rofi para exibir dispositivos e permitir selecionar
    selected_device=$(echo -e "$devices_with_marker" | rofi -dmenu -p "Escolha o dispositivo de áudio:" -theme Arc-Dark)

    # Se um dispositivo for selecionado
    if [ -n "$selected_device" ]; then
      # Extrair o nome do dispositivo selecionado (remover o "(default)" se presente)
      device_name=$(echo "$selected_device" | sed 's/ (default)//')

      # Definir o dispositivo selecionado como o padrão
      pactl set-default-source "$device_name"
    fi
fi
