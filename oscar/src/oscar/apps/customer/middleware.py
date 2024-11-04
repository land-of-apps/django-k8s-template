import time
from django.conf import settings
from django.http import HttpResponse
from django.core.cache import cache

class ThrottleMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        ip = self.get_client_ip(request)
        request_count, last_request_time = cache.get(ip, (0, time.time()))

        # Calculate delay based on request count
        if request_count >= settings.THROTTLE_MAX_REQUESTS:
            delay = (request_count - settings.THROTTLE_MAX_REQUESTS + 1) * settings.THROTTLE_DELAY_INCREMENT
            time_since_last_request = time.time() - last_request_time
            if time_since_last_request < delay:
                return HttpResponse("Too many requests. Please try again later.", status=429)

        # Update request count and time
        cache.set(ip, (request_count + 1, time.time()), timeout=settings.THROTTLE_BLOCK_DURATION)

        response = self.get_response(request)
        return response

    def get_client_ip(self, request):
        x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')
        if x_forwarded_for:
            ip = x_forwarded_for.split(',')[0]
        else:
            ip = request.META.get('REMOTE_ADDR')
        return ip
