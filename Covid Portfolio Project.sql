select * 
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

select * 
from PortfolioProject..CovidVaccinations
order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2



--looking at total cases vs total deaths 
--Likely hood of dying from covid based on time and location

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 'DeathPercentage'
from PortfolioProject..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2;



--looking at total cases vs population
--the percentage of population that got covid

select location, date, population, total_cases, (total_cases/population)*100 'InfectionPercentage'
from PortfolioProject..CovidDeaths
--where location like '%states%'
order by 1,2





--looking at countries with highest infection rate compared to population
select location, population, max(total_cases) 'HighestInfectionCount', max((total_cases/population))*100 'InfectionPercentage'
from PortfolioProject..CovidDeaths
--where location like '%states%'
group by location, population
order by InfectionPercentage desc




--Countries with highest death count per population
--looking at countries with highest infection rate compared to population

select location, max(cast(Total_deaths as int)) 'TotalDeathCount'
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc


--BREAKING THINGS DOWN BY CONTINENT

select continent, max(cast(Total_deaths as int)) 'TotalDeathCount'
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc

--Showing continent with with highest death count per population

select continent, max(cast(Total_deaths as int)) 'TotalDeathCount'
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc


--GLOBAL NUMBERS	

select date, sum(new_cases) 'total_cases', sum(cast(new_deaths as int)) 'total_deaths', sum(cast(new_deaths as int))/sum(new_cases)*100 'DeathPecentage'
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by date
order by 1,2





--Looking at total population vs vaccinations

with PopvsVac (Continent, location, date, population, New_vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, 
dea.date) 'RollingPeopleVaccinated'
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
	join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select * ,(RollingPeopleVaccinated/ population)*100
from PopvsVac

--CTE
--TEMP TABLE

Drop Table if Exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, 
dea.date) 'RollingPeopleVaccinated'
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
	join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null

select *, (RollingPeopleVaccinated/ population)*100
from #PercentPopulationVaccinated





--View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

select *
from PercentPopulationVaccinated

