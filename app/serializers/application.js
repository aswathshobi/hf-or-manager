import RESTSerializer from '@ember-data/serializer/rest';

export default class ApplicationSerializer extends RESTSerializer {
  primaryKey = 'id';
  
  normalizeResponse(store, primaryModelClass, payload, id, requestType) {
    if (Array.isArray(payload)) {
      payload = payload.map(item => {
        if (item.employee && typeof item.employee === 'object') {
          return item.employee;
        }
        return item;
      });
      const modelName = primaryModelClass.modelName;
      payload = { [modelName]: payload };
    }
    
    return super.normalizeResponse(store, primaryModelClass, payload, id, requestType);
  }
  
  serialize(snapshot) {
    const data = {
      id: snapshot.id,
      name: snapshot.attr('name'),
      designation: snapshot.attr('designation'),
      team: snapshot.attr('team'),
      manager: null
    };
    const managerId = snapshot.belongsTo('manager', { id: true });
    if (managerId) {
      data.manager = managerId;
    }
    return data;
  }
  
  serializeIntoHash(hash, typeClass, snapshot, options) {
    Object.assign(hash, this.serialize(snapshot, options));
  }
}

