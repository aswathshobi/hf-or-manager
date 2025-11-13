import RESTAdapter from '@ember-data/adapter/rest';
import ENV from 'org-manager/config/environment';

export default class ApplicationAdapter extends RESTAdapter {
  get host() {
    // Use environment variable in production, localhost in development
    return ENV.apiHost || 'https://org-s.onrender.com';
  }
  
  namespace = '';
  
  pathForType(modelName) {
    return modelName + 's';
  }
}
