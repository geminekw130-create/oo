importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-messaging.js");

// Configuração do Firebase - usando valores corretos do seu projeto
firebase.initializeApp({
  apiKey: "AIzaSyDp58F_Sdf-CrcwUb8ZizIV7zCVEjIB1FI",
  authDomain: "to-chegando-motoboy-24b4a.firebaseapp.com",
  projectId: "to-chegando-motoboy-24b4a",
  storageBucket: "to-chegando-motoboy-24b4a.firebasestorage.app",
  messagingSenderId: "491950036407",
  // Usando o appId de um dos apps Android (recomendado para melhor compatibilidade em background no Android)
  appId: "1:491950036407:android:e1cdffd7cc7cd147034432",
  databaseURL: "https://to-chegando-motoboy-24b4a-default-rtdb.firebaseio.com"
});

const messaging = firebase.messaging();

/**
 * Tratamento de mensagens em background (app fechado ou em segundo plano)
 */
messaging.onBackgroundMessage(function (payload) {
  console.log("[firebase-messaging-sw.js] Mensagem recebida em background:", payload);

  // Título e corpo da notificação
  const notificationTitle = payload.notification?.title || "ToChegando";
  const notificationOptions = {
    body: payload.notification?.body || "Você tem uma nova notificação.",
    icon: "/icons/icon-192.png",        // Certifique-se que esse arquivo existe na pasta web/icons/
    badge: "/icons/icon-72.png",        // Opcional: ícone pequeno na barra de notificações
    image: payload.notification?.image || undefined, // Se tiver imagem na notificação
    tag: "tochegando-notification",     // Evita notificações duplicadas
    renotify: true,                     // Vibra novamente se for a mesma tag
    requireInteraction: false,          // Fecha automaticamente ao clicar (padrão)
    data: payload.data || {},           // Dados customizados para usar ao clicar
    actions: [                          // Botões opcionais na notificação (Android)
      {
        action: "open_app",
        title: "Abrir App"
      },
      {
        action: "close",
        title: "Fechar"
      }
    ]
  };

  // Exibe a notificação
  return self.registration.showNotification(notificationTitle, notificationOptions);
});

/**
 * Evento de clique na notificação
 */
self.addEventListener("notificationclick", function (event) {
  console.log("[firebase-messaging-sw.js] Notificação clicada:", event);

  event.notification.close();

  // Dados customizados enviados na notificação (ex: tipo de ação, URL, etc.)
  const data = event.notification.data || {};
  const urlToOpen = data.click_action || "/"; // Use uma URL específica se enviada no payload

  event.waitUntil(
    clients.matchAll({ type: "window", includeUncontrolled: true }).then(function (clientList) {
      // Se já houver uma janela aberta, foca nela
      for (const client of clientList) {
        if ("focus" in client) {
          return client.focus();
        }
      }
      // Caso contrário, abre uma nova janela
      if (clients.openWindow) {
        return clients.openWindow(urlToOpen);
      }
    })
  );
});