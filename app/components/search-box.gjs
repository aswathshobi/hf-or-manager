import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { on } from '@ember/modifier';

export default class SearchBoxComponent extends Component {
  @tracked searchTerm = '';

  @action
  updateSearch(event) {
    this.searchTerm = event.target.value;
    this.args.onSearch?.(this.searchTerm);
  }

  @action
  clearSearch() {
    this.searchTerm = '';
    this.args.onSearch?.('');
  }

  <template>
    <div class="search-box">
      <div class="search-box__input-wrapper">
        <svg class="search-box__icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <circle cx="11" cy="11" r="8"></circle>
          <path d="m21 21-4.35-4.35"></path>
        </svg>
        <input
          type="text"
          class="search-box__input"
          placeholder={{@placeholder}}
          value={{this.searchTerm}}
          {{on "input" this.updateSearch}}
        />
        {{#if this.searchTerm}}
          <button
            type="button"
            class="search-box__clear"
            {{on "click" this.clearSearch}}
          >
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <line x1="18" y1="6" x2="6" y2="18"></line>
              <line x1="6" y1="6" x2="18" y2="18"></line>
            </svg>
          </button>
        {{/if}}
      </div>
    </div>
  </template>
}
