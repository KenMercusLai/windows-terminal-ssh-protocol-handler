# run the command as add_venue.py venue_id venue_name address state region_name
# docker run -t --rm doraemon_tabcorp_sdwan_worker python /app/add_venue.py 1404606 "Rivett LPO & Newsagency" "Shop 5, 2 Rivett Place" ACT "Rivett, 2611"
import sys
from typing import List

from slugify import slugify

from common import nb, logger, add_find_tag, find_suburb, find_next_unused_prefix, add_find_site



def main():
    _, venue_id, name, address, state, suburb_postal, line_of_business = sys.argv
    suburb, postal = [i.strip() for i in suburb_postal.split(',')]
    line_of_business = [i.strip() for i in line_of_business.split(',')]
    add_venue(venue_id, name, address, state, suburb, postal, line_of_business)


if __name__ == '__main__':
    main()
