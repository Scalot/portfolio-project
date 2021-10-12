select*
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select*
--from PortfolioProject..CovidVaccinations
--order by 3,4

--select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

--looking at total cases vs total deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
Where location like '%Japan%'
order by 1,2


--looking at total cases vs population

select location, date,population,total_cases,  (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--Where location like '%India%'
order by 1,2

--looking at countries with highest infection rate compare to population

select location, population, Max (total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--Where location like '%India%'
group by location, population
order by PercentPopulationInfected desc

--showing countries with highest death count per population

select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--Where location like '%India%'
where continent is not null
group by location
order by TotalDeathCount desc



-- showing continent with highest death cout per population

select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--Where location like '%India%'
where continent is not null
group by continent
order by TotalDeathCount desc



-- global numbers

select date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--Where location like '%India%'
where continent is not null
order by 1,2


--looking at totalk population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null  
order by 2,3

--use CTE
with PopvsVac (continent,location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date ) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null
--order by 2,3
)

select *, (RollingPeopleVaccinated/population)*100
from PopvsVac



--temp table
drop table if exists PercentPopulationVaccinated
create table PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccination numeric,
RollingPeopleVaccinated numeric
)
insert into PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null 
order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from PercentPopulationVaccinated


--creating view to store data for later visualization

create view PercentPopulationVaccinateds as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null 
--order by 2,3


select * 
from PercentPopulationVaccinateds