import { LightningElement, api } from 'lwc';
import reopenCase from '@salesforce/apex/CaseRequestController.reopenCase';
import contactSupport from '@salesforce/apex/CaseRequestController.contactSupport';
import getCaseDetails from '@salesforce/apex/CaseRequestController.getCaseDetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CaseStatusComponent extends LightningElement {
    @api recordId;

    slaDeadline;
    status;
    countdown = '';
    countdownClass = '';
    canReopen = false;
    showComponent = false;
    isPremium = false;
    slaExpiredNotice = false;

    countdownInterval;

    connectedCallback() {
        this.loadData();
    }

    async loadData() {
        try {
            const result = await getCaseDetails({ caseId: this.recordId });
            this.slaDeadline = result.SLA_Deadline__c ? new Date(result.SLA_Deadline__c) : null;
            this.status = result.Status__c;
            this.isPremium = result.RecordType.DeveloperName === 'Premium';
            this.showComponent = true;

            this.updateCountdown();

            this.countdownInterval = setInterval(() => this.updateCountdown(), 60000);

        } catch (error) {
            console.error('Error loading case details:', error);
            this.showComponent = false;
        }
    }

    disconnectedCallback() {
        clearInterval(this.countdownInterval);
    }

    get showCountdown() {
        return !!this.slaDeadline && !isNaN(this.slaDeadline.getTime());
    }

    get countdownDisplayClass() {
        return `countdown-display ${this.countdownClass}`;
    }

    updateCountdown() {
        if (!this.slaDeadline || isNaN(this.slaDeadline.getTime())) {
            this.countdown = 'No deadline set';
            this.countdownClass = 'countdown-no-deadline';
            this.slaExpiredNotice = false;
            this.canReopen = this.status === 'Closed';
            return;
        }

        const now = new Date();
        const deadline = this.slaDeadline;
        const diffMs = deadline - now;

        if (diffMs <= 0) {
            this.countdown = 'Deadline passed';
            this.countdownClass = 'countdown-expired';
            this.slaExpiredNotice = true;
            this.canReopen = this.status === 'Closed';
            return;
        }

        this.slaExpiredNotice = false;

        const hours = Math.floor(diffMs / (1000 * 60 * 60));
        const minutes = Math.floor((diffMs % (1000 * 60 * 60)) / (1000 * 60));
        const seconds = Math.floor((diffMs % (1000 * 60)) / 1000);

        let countdownText;
        if (hours > 24) {
            const days = Math.floor(hours / 24);
            const remainingHours = hours % 24;
            countdownText = `${days}d ${remainingHours}h remaining`;
        } else if (hours >= 1) {
            countdownText = `${hours}h ${minutes}m remaining`;
        } else if (minutes >= 1) {
            countdownText = `${minutes}m ${seconds}s remaining`;
        } else {
            countdownText = `${seconds}s remaining`;
        }

        if (hours < 1) {
            this.countdownClass = 'countdown-warning';
            if (hours <= 0 && minutes < 30) {
                this.countdownClass = 'countdown-urgent';
            }
        } else {
            this.countdownClass = 'countdown-normal';
        }

        this.countdown = countdownText;
        this.canReopen = this.status === 'Closed';
    }

    async handleReopen() {
        try {
            await reopenCase({ caseId: this.recordId });
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Case reopened successfully',
                    variant: 'success'
                })
            );
            await this.loadData();
        } catch (error) {
            console.error('Error reopening case', error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Failed to reopen case: ' + (error.body?.message || error.message),
                    variant: 'error'
                })
            );
        }
    }

    async handleContactSupport() {
        try {
            await contactSupport({ caseId: this.recordId });
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Support has been contacted!',
                    variant: 'success'
                })
            );
        } catch (error) {
            console.error('Error contacting support:', error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Failed to contact support: ' + (error.body?.message || error.message),
                    variant: 'error'
                })
            );
        }
    }
}
