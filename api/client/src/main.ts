import { createApp } from 'vue';
import { createPinia } from 'pinia';
import 'vuetify/styles';
import { createVuetify } from 'vuetify';
import * as components from 'vuetify/components';
import * as directives from 'vuetify/directives';
import { mdiAccount, mdiLogout, mdiPlus, mdiPencil, mdiDelete, mdiMagnify, mdiRefresh, mdiLogin } from '@mdi/js';

import App from '@/App.vue';
import router from '@/router';

const vuetify = createVuetify({
  components,
  directives,
  icons: {
    values: {
      account: mdiAccount,
      logout: mdiLogout,
      plus: mdiPlus,
      pencil: mdiPencil,
      delete: mdiDelete,
      magnify: mdiMagnify,
      refresh: mdiRefresh,
      login: mdiLogin,
    },
  },
  theme: {
    defaultTheme: 'light',
  },
});

const app = createApp(App);

app.use(createPinia());
app.use(router);
app.use(vuetify);

app.mount('#app');
