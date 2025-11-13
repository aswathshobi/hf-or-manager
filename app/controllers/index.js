import Controller from '@ember/controller';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { service } from '@ember/service';

export default class IndexController extends Controller {
  @service store;
  
  @tracked filteredEmployees = null;

  getAncestors(employee, allEmployees) {
    const ancestors = [];
    let current = employee;
    
    while (current) {
      const managerId = current.manager?.get ? current.manager.get('id') : current.manager;
      if (!managerId) break;
      
      const manager = allEmployees.find(emp => emp.id === managerId);
      if (!manager) break;
      
      ancestors.push(manager);
      current = manager;
    }
    
    return ancestors;
  }

  get displayedEmployees() {
    if (!this.filteredEmployees) {
      return this.model;
    }

    const allEmployees = this.model.slice();
    const employeesToShow = new Set();

    this.filteredEmployees.forEach(emp => {
      employeesToShow.add(emp.id);
      
      const ancestors = this.getAncestors(emp, allEmployees);
      ancestors.forEach(ancestor => employeesToShow.add(ancestor.id));
    });

    return allEmployees.filter(emp => employeesToShow.has(emp.id));
  }

  @action
  handleFilterChange(employees) {
    this.filteredEmployees = employees;
  }

  @action
  async handleEmployeeUpdate() {
    const employees = await this.store.findAll('employee', { reload: true });
    
    if (this.filteredEmployees) {
      const filteredIds = new Set(this.filteredEmployees.map(e => e.id));
      
      this.filteredEmployees = employees.filter(emp => filteredIds.has(emp.id));
    }
    
    this.filteredEmployees = this.filteredEmployees ? [...this.filteredEmployees] : null;
  }
}
