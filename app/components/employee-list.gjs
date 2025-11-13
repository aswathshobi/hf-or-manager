import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import SearchBox from './search-box';
import TeamFilter from './team-filter';

export default class EmployeeListComponent extends Component {
  @tracked searchTerm = '';
  @tracked selectedTeam = null;

  get uniqueTeams() {
    if (!this.args.employees) return [];
    
    const teams = new Set();
    this.args.employees.forEach(employee => {
      if (employee.team) {
        teams.add(employee.team);
      }
    });
    return Array.from(teams).sort();
  }

  get filteredEmployees() {
    if (!this.args.employees) return [];
    
    let filtered = this.args.employees.slice();

    // Apply team filter
    if (this.selectedTeam) {
      filtered = filtered.filter(emp => emp.team === this.selectedTeam);
    }

    // Apply search filter
    if (this.searchTerm) {
      const searchLower = this.searchTerm.toLowerCase();
      filtered = filtered.filter(emp => {
        return (
          emp.name?.toLowerCase().includes(searchLower) ||
          emp.designation?.toLowerCase().includes(searchLower) ||
          emp.team?.toLowerCase().includes(searchLower)
        );
      });
    }

    return filtered;
  }

  get employeeCount() {
    return this.filteredEmployees.length;
  }

  notifyFilterChange() {
    this.args.onFilterChange?.(this.filteredEmployees);
  }

  @action
  handleSearch(searchTerm) {
    this.searchTerm = searchTerm;
    this.notifyFilterChange();
  }

  @action
  handleTeamFilter(team) {
    this.selectedTeam = team;
    this.notifyFilterChange();
  }

  <template>
    <div class="employee-list">
      <h2 class="employee-list__title">
        Employees
        <span class="employee-list__count">{{this.employeeCount}}</span>
      </h2>
      
      <SearchBox 
        @placeholder="Search by name, role, or team..." 
        @onSearch={{this.handleSearch}} 
      />
      
      <TeamFilter 
        @teams={{this.uniqueTeams}} 
        @onFilter={{this.handleTeamFilter}} 
      />
      
      <div class="employee-list__items">
        {{#if this.filteredEmployees.length}}
          {{#each this.filteredEmployees as |employee|}}
            <div class="employee-item">
              <h3 class="employee-item__name">{{employee.name}}</h3>
              <p class="employee-item__designation">{{employee.designation}}</p>
              <p class="employee-item__team">{{employee.team}}</p>
            </div>
          {{/each}}
        {{else}}
          <div class="employee-list__empty">
            <svg class="employee-list__empty-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <circle cx="11" cy="11" r="8"></circle>
              <path d="m21 21-4.35-4.35"></path>
            </svg>
            <p class="employee-list__empty-text">No employees found</p>
            <p class="employee-list__empty-hint">Try adjusting your search or filters</p>
          </div>
        {{/if}}
      </div>
    </div>
  </template>
}
