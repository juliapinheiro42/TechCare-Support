import { LightningElement, api, wire } from 'lwc';
import getHistory from '@salesforce/apex/CaseHistoryController.getHistory';

export default class CaseHistoryTimeline extends LightningElement {
  @api recordId;
  history = [];
  error;

  @wire(getHistory, { caseId: '$recordId' })
  wiredHistory({ error, data }) {
    if (data) {
      this.history = data;
      this.error = null;
    } else if (error) {
      this.error = error;
      this.history = [];
    }
  }
  get hasHistory() {
  return this.history && this.history.length > 0;
}

}
