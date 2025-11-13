import Model, { attr, belongsTo } from '@ember-data/model';

export default class EmployeeModel extends Model {
  @attr('string') name;
  @attr('string') designation;
  @attr('string') team;
  @belongsTo('employee', { inverse: null, async: true }) manager;
}
