use covid_project;
select * from covid_data;

select location, count(location) from covid_data group by location order by location 
select * from covid_data;
select location, total_cases, total_deaths, date from covid_data;

-- Looking at total cases and total deaths.
select location, total_cases, total_deaths, date, (total_cases/total_deaths)*100 as death_percent
from covid_data where location like '%india%';


-- Looking at the total cases vs population
select location, total_cases, population, date, (total_cases/population)*100 as death_percent
from covid_data where location like '%india%';

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
round(sum(cast(new_deaths as int))/sum(new_cases)*100, 2) as total_death_percentage from covid_data
where continent is not null order by total_deaths;


-- countries with highest infected rate compared with population
select location, population, max(total_cases) as highest_infected,
round(max((total_cases/population)*100), 2) as infected_percentage
from covid_data group by location, population order by infected_percentage desc;


select location, population, date, max(total_cases) as highest_infected,
round(max((total_cases/population)*100), 2) as highest_infected_percentage from covid_data
group by location, population, date
order by highest_infected_percentage desc;


-- countries with high count of death as per population.
-- changing the data type of total_deaths into int
select location, max(cast(total_deaths as int)) as max_deaths, population from covid_data 
group by location, population order by max_deaths desc;


-- break the things by continent

-- Showing the continent with the highest deaths as per population.
select continent, sum(population) as population, sum(cast(total_deaths as int)) as total_deaths,
(sum(cast(total_deaths as int))/sum(population))*100 as total_death_percentage
from covid_data where continent is not null
group by continent order by total_deaths desc;

select continent, sum(cast(new_deaths as int)) as total_death_count from covid_data where continent is not null
group by continent order by total_death_count desc;

select * from covid_data


-- Global Numbers.
select continent, sum(new_cases) as new_cases, sum(cast(new_deaths as int)) as new_deaths,
round(sum(cast(new_deaths as int))/sum(new_cases)*100, 1) as death_percentage
from covid_data where continent is not null
group by continent



-- looking at total population vs vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as added_people_vaccinated

from covid_data as dea
join
CovidVaccination as vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- use CTE(common table expression)
with pop_vs_vac (continent, location, date, popoulation, new_vaccinations, added_people_vaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as added_people_vaccinated
from covid_data as dea
join
CovidVaccination as vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (added_people_vaccinated/popoulation)*100 as total_people_vaccinated_percent from pop_vs_vac


-- Temp table
drop table if exists percent_people_vaccinated
create table percent_people_vaccinated(continent nvarchar(255), location nvarchar(255), date datetime, population numeric,
new_vaccinations numeric, added_people_vaccinated numeric)

insert into percent_people_vaccinated select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as added_people_vaccinated
from covid_data as dea
join
CovidVaccination as vac
on dea.location = vac.location and dea.date = vac.date
--where dea.continent is not null
order by 2,3
select *, (added_people_vaccinated/population)*100 from percent_people_vaccinated


-- Creating view for the visualization

create view percent_population_vaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as added_people_vaccinated
from covid_data as dea
join
CovidVaccination as vac
on dea.location = vac.location and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select * from percent_population_vaccinated



