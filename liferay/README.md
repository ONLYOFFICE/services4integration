# Стенд для тестирования коннектора к Liferay

Перед созданием ВМ в oVirt загрузите тестируемый коннектор на хост 37.61.218.148 в директорию `/connectors/liferay` с помощью команды:
```
scp -o StrictHostKeyChecking=no -i ~/.ssh/connectors /tmp/onlyoffice.integration.web* onlyoffice@37.61.218.148:/connectors/liferay/
```

Где:
 - `~/.ssh/connectors` – путь до закрытого ключа
 - `tmp/onlyoffice.integration.web` – путь до тестируемого коннектора на локальном компьютере

Название коннектора должно начинаться с `onlyoffice.integration.web`, т. к. оно используется в скрипте установки.

После загрузки коннектора создайте ВМ в oVirt, при этом, во вкладе `Initial Run` в поле `Custom Script` введите следующие команды:
```
runcmd:
 - git clone https://username:password@github.com/ONLYOFFICE/services4integration.git /app
 - /app/liferay/install_liferay.sh <liferay_tag> 
```

Где `liferay_tag` – версия liferay. 

Если тег не указывать по умолчанию будет установлена версия `7.4.0-ga1`.

После этого можно подключиться по SSH к ВМ и проверить ход выполнения скрипта с помощью команды:
```
sudo tail -f /var/log/cloud-init-output.log
```

При успешном выполнении появится надпись:
``` 
The script is finished
```

Далее можно переходить в веб-интерфейс Liferay по адресу: `http://IP-SERVER/` и проверить работу коннектора.

