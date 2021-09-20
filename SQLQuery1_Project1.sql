select * from CovidDeths;
select * from CovidVaccinations;

--total cases vs total deths
select Location,Date, Total_cases, new_cases, total_deaths, population
from CovidDeths
where continent is not null
order by location, date;

--Deth Percentage
select Location,Date, Total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DethPercentage
from CovidDeths
where location like '%Sri Lanka%'
and continent is not null
order by location, date;

--covid infected percentage
select Location,Date, Total_cases, population, (total_cases/population)*100 as CasesPercentage
from CovidDeths
where location like '%Sri Lanka%'
and continent is not null
order by location, date;

--countries with highest infection rate
select Location,max(Total_cases) as MaxCases, max((total_cases/population))*100 as MaxCasesPercentage
from CovidDeths
--where location like '%Sri Lanka%'
where continent is not null
group by location
order by MaxCasesPercentage desc;

--countries with highest death count
select Location,max(cast (total_deaths as int)) as MaxDeaths
from CovidDeths
--where location like '%Sri Lanka%'
where continent is not null
group by location
order by MaxDeaths desc;

--continents with highest death count
select Location,max(cast (total_deaths as int)) as MaxDeaths
from CovidDeths
where continent is  null
group by location
order by MaxDeaths desc;

select continent,max(cast (total_deaths as int)) as MaxDeaths
from CovidDeths
where continent is not null
group by continent
order by MaxDeaths desc;

--Global
select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeths
where continent is not null
--group by date
order by date,TotalCases ;

--total population vs vaccination
select a.continent,a.location, a.date, a.population, b.new_vaccinations, sum(cast(b.new_vaccinations as int)) over 
(partition by  a.location order by a.location, a.date) as RollingPeopleVaccinated
from  CovidDeths a
join CovidVaccinations b 
	on a.date =b.date
	and a.location = b.location
	and a.continent is not null
	order by a.location, a.date;

--use CTE
with PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) as
(select a.continent,a.location, a.date, a.population, b.new_vaccinations, sum(cast(b.new_vaccinations as int)) over 
(partition by  a.location order by a.location, a.date) as RollingPeopleVaccinated
from  CovidDeths a
join CovidVaccinations b 
	on a.date =b.date
	and a.location = b.location
	and a.continent is not null
	--order by a.location, a.date
)
select a.*, (RollingPeopleVaccinated/population *100)
from PopVsVac a;

--TEMP table
drop table if exists tmp_PopVsVac
create table tmp_PopVsVac (
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into tmp_PopVsVac
select a.continent,a.location, a.date, a.population, b.new_vaccinations, sum(cast(b.new_vaccinations as int)) over 
(partition by  a.location order by a.location, a.date) as RollingPeopleVaccinated
from  CovidDeths a
join CovidVaccinations b 
	on a.date =b.date
	and a.location = b.location
	and a.continent is not null
	--order by a.location, a.date

select a.*, (RollingPeopleVaccinated/population *100)
from tmp_PopVsVac a;

---creating views------------------------------------------------------------------------------------
create view view_totalcases_vs_totaldeths as 
select Location,Date, Total_cases, new_cases, total_deaths, population
from CovidDeths
where continent is not null
--order by location, date

select * from view_totalcases_vs_totaldeths; 

create view view_DethPercentage as
select Location,Date, Total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DethPercentage
from CovidDeths
--where location like '%Sri Lanka%'
where continent is not null

select * from view_DethPercentage; 

