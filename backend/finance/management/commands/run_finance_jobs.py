from django.core.management.base import BaseCommand

from finance.profit_service import credit_monthly_investment_returns
from stocks.alert_service import process_price_alerts
from stocks.sip_service import process_due_sip_installments


class Command(BaseCommand):
    help = 'Run scheduled finance jobs: SIP installments, price alerts, investment returns'

    def add_arguments(self, parser):
        parser.add_argument('--sip', action='store_true', help='Process due SIP installments')
        parser.add_argument('--alerts', action='store_true', help='Check price alerts')
        parser.add_argument('--profits', action='store_true', help='Credit monthly investment returns')
        parser.add_argument('--all', action='store_true', help='Run all jobs')

    def handle(self, *args, **options):
        run_all = options['all'] or not any([options['sip'], options['alerts'], options['profits']])

        if run_all or options['sip']:
            count = process_due_sip_installments()
            self.stdout.write(self.style.SUCCESS(f'SIP: processed {count} installment(s).'))

        if run_all or options['alerts']:
            count = process_price_alerts()
            self.stdout.write(self.style.SUCCESS(f'Alerts: triggered {count} alert(s).'))

        if run_all or options['profits']:
            count = credit_monthly_investment_returns()
            self.stdout.write(self.style.SUCCESS(f'Profits: credited {count} investment return(s).'))
