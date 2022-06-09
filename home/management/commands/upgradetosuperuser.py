from allauth.account.models import EmailAddress
from django.core.management.base import BaseCommand, CommandParser


class Command(BaseCommand):
    help = "Upgrade user to a superuser previlage"

    def add_arguments(self, parser: CommandParser) -> None:
        parser.add_argument(
            "--email",
            dest="email",
            help="Specifies the email address of app user to upgrade as the superuser.",
        )

    def handle(self, *args, **kwargs) -> None:
        email = kwargs.get("email")
        if email:
            try:
                email_address = EmailAddress.objects.get(
                    email=email, verified=True, user__is_active=True
                )  # only upgrade verified and active user
                email_address.user.is_superuser = True
                email_address.user.is_staff = True
                email_address.user.save()
                self.stdout.write(
                    self.style.SUCCESS(
                        f"Successfully upgraded user {email} to superuser."
                    )
                )
            except EmailAddress.DoesNotExist:
                self.stdout.write(
                    self.style.ERROR(
                        f"User {email} does not exist or not active or verified"
                    )
                )
        else:
            self.stdout.write(self.style.ERROR(f"No email address provided."))
