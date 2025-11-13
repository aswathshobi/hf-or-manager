import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { on } from '@ember/modifier';

export default class TeamFilterComponent extends Component {
  @tracked selectedTeam = 'all';

  get teams() {
    return this.args.teams || [];
  }

  @action
  updateFilter(event) {
    this.selectedTeam = event.target.value;
    this.args.onFilter?.(this.selectedTeam === 'all' ? null : this.selectedTeam);
  }

  <template>
    <div class="team-filter">
      <label class="team-filter__label" for="team-select">
        <svg class="team-filter__icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <path d="M3 6h18M7 12h10M10 18h4"></path>
        </svg>
        Filter by Team
      </label>
      <select
        id="team-select"
        class="team-filter__select"
        {{on "change" this.updateFilter}}
      >
        <option value="all">All Teams</option>
        {{#each this.teams as |team|}}
          <option value={{team}}>{{team}}</option>
        {{/each}}
      </select>
    </div>
  </template>
}
