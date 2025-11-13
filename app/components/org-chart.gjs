import Component from '@glimmer/component';
import { action } from '@ember/object';
import { service } from '@ember/service';
import { OrgChart } from 'd3-org-chart';
import { convertToD3Format } from '../utils/hierarchy';
import { modifier } from 'ember-modifier';

export default class OrgChartComponent extends Component {
  @service store;
  
  chart = null;
  chartContainer = null;

  setupChart = modifier((element) => {
    this.chartContainer = element;
    this.renderChart();
  });

  updateChart = modifier((element, [employees]) => {
    this.renderChart();
  });

  @action
  async handleEmployeeDrop(draggedEmployeeId, newManagerId) {
    try {

      const employee = await this.store.findRecord('employee', draggedEmployeeId);
      
      if (!employee) {
        return;
      }

      let newManager = null;
      if (newManagerId && newManagerId !== '') {
        newManager = await this.store.findRecord('employee', newManagerId);
      }

      employee.manager = newManager;

      await employee.save();

      await this.args.onEmployeeUpdate?.();
      
    } catch (error) {
      
      await this.args.onEmployeeUpdate?.();
    }
  }

  @action
  renderChart() {
    if (!this.chartContainer) return;

    const employees = this.args.employees || [];
    const data = convertToD3Format(employees);

    if (data.length === 0) {
      this.chartContainer.innerHTML = `
        <div class="org-chart__empty">
          <svg class="org-chart__empty-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path>
            <circle cx="9" cy="7" r="4"></circle>
            <path d="M23 21v-2a4 4 0 0 0-3-3.87"></path>
            <path d="M16 3.13a4 4 0 0 1 0 7.75"></path>
          </svg>
          <h3 class="org-chart__empty-title">No Organization Data</h3>
          <p class="org-chart__empty-text">Select employees from the sidebar to view the organizational hierarchy</p>
        </div>
      `;
      return;
    }

    if (!this.chart) {
      this.chart = new OrgChart();
    }

    this.chart
      .container(this.chartContainer)
      .data(data)
      .nodeWidth(() => 280)
      .nodeHeight(() => 120)
      .childrenMargin(() => 50)
      .compactMarginBetween(() => 35)
      .compactMarginPair(() => 30)
      .neighbourMargin(() => 50)
      .siblingsMargin(() => 50)
      .buttonContent(() => '')
      .linkUpdate(function() {})
      .nodeUpdate(function() {})
      .onNodeClick((d) => {
        console.log('Node clicked:', d.data);
      })
      .nodeContent((d) => {
        const initials = d.data.name
          .split(' ')
          .map(part => part[0])
          .join('')
          .toUpperCase()
          .slice(0, 2);

        return `
          <div class="org-chart-node" draggable="true" data-employee-id="${d.data.id}">
            <div class="org-chart-node__avatar">${initials}</div>
            <div class="org-chart-node__info">
              <div class="org-chart-node__name">${d.data.name}</div>
              <div class="org-chart-node__designation">${d.data.designation}</div>
              <div class="org-chart-node__team">${d.data.team}</div>
            </div>
          </div>
        `;
      })
      .render()
      .expandAll();
    
    if (this.chart.getChartState()) {
      const svg = this.chartContainer.querySelector('svg');
      if (svg) {
        // Remove d3 drag behavior from svg
        svg.style.cursor = 'default';
        const gElement = svg.querySelector('g');
        if (gElement) {
          gElement.style.pointerEvents = 'none';
        }
      }
    }
    
    setTimeout(() => {
      this.setupDragAndDrop();
    }, 100);
  }

  @action
  setupDragAndDrop() {
    if (!this.chartContainer) return;

    let draggedEmployeeId = null;

    const nodes = this.chartContainer.querySelectorAll('.org-chart-node');
    
    nodes.forEach(node => {
      node.style.pointerEvents = 'auto';
      
      node.addEventListener('mousedown', (e) => {
        e.stopPropagation();
      });

      node.addEventListener('dragstart', (e) => {
        draggedEmployeeId = node.getAttribute('data-employee-id');
        e.dataTransfer.effectAllowed = 'move';
        e.dataTransfer.setData('text/plain', draggedEmployeeId);
        node.classList.add('dragging');
        e.stopPropagation();
      });

      node.addEventListener('dragend', (e) => {
        node.classList.remove('dragging');
        this.chartContainer.querySelectorAll('.drop-target').forEach(el => {
          el.classList.remove('drop-target');
        });
        e.stopPropagation();
      });

      node.addEventListener('dragover', (e) => {
        if (node.getAttribute('data-employee-id') !== draggedEmployeeId) {
          e.preventDefault();
          e.dataTransfer.dropEffect = 'move';
          node.classList.add('drop-target');
        }
        e.stopPropagation();
      });

      node.addEventListener('dragleave', (e) => {
        node.classList.remove('drop-target');
        e.stopPropagation();
      });

      node.addEventListener('drop', (e) => {
        e.preventDefault();
        e.stopPropagation();
        
        const newManagerId = node.getAttribute('data-employee-id');
        
        if (newManagerId !== draggedEmployeeId && draggedEmployeeId) {
          this.handleEmployeeDrop(draggedEmployeeId, newManagerId);
        }
        
        node.classList.remove('drop-target');
        draggedEmployeeId = null;
      });
    });
  }

  willDestroy() {
    super.willDestroy(...arguments);
    if (this.chart) {
      this.chart = null;
    }
  }

  <template>
    <div class="org-chart" {{this.setupChart}} {{this.updateChart @employees}}>
    </div>
  </template>
}
